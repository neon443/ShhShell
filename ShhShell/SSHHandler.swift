//
//  SSHHandler.swift
//  ShhShell
//
//  Created by neon443 on 05/06/2025.
//

import Foundation
import LibSSH
import OSLog

class SSHHandler: ObservableObject {
	var session: ssh_session?

	private let logger = Logger(subsystem: "xy", category: "sshHandler")

	init() {
//		session = ssh_new()
//		guard session != nil else { return }
	}

	func connect() {
		var verbosity: Int = 0
		var port: Int = 2222

		session = ssh_new()
		guard session != nil else {
			fatalError("no ssh session??!?!")
		}

		ssh_options_set(session, SSH_OPTIONS_HOST, "localhost")
		ssh_options_set(session, SSH_OPTIONS_LOG_VERBOSITY, &verbosity)
		ssh_options_set(session, SSH_OPTIONS_PORT, &port)

		let status = ssh_connect(session)
		if status != SSH_OK {
			logger.critical("connection not ok: \(status)")
			logSshGetError()
			fatalError()
		}
	}

	func disconnect() {
		guard session != nil else { fatalError("no ssession") }
		ssh_disconnect(session)
	}

	func hardcodedAuth() {
		var hostkey: ssh_key?
		ssh_get_server_publickey(session, &hostkey)
		if let hostkey = hostkey {
			print("hostkey \(hostkey)")
		}

		let password = "root"

		let rc = ssh_userauth_password(session, "root", password)
		if rc != SSH_AUTH_SUCCESS.rawValue {
			print("auth failure")
		}
	}

	func testExec() {
		connect()
		defer { disconnect();ssh_free(session) }

		hardcodedAuth()

		var status: CInt
		var buffer: [Int] = Array(repeating: 0, count: 256)
		var nbytes: CInt

		let channel = ssh_channel_new(session)
		guard channel != nil else { fatalError("noChannel") }

		status = ssh_channel_open_session(channel)
		guard status == SSH_OK else {
			ssh_channel_free(channel)
			logger.critical("session opening error")
			logSshGetError()
			return
		}

		status = ssh_channel_request_exec(channel, "uptime")
		guard status == SSH_OK else {
			ssh_channel_close(channel)
			ssh_channel_free(channel)
			logger.critical("session opening error")
			logSshGetError()
			return
		}
		
		nbytes = ssh_channel_read(
			channel,
			&buffer,
			UInt32(MemoryLayout.size(ofValue: CChar.self)),
			0
		)
		while nbytes > 0 {
			let written = write(1, buffer, Int(nbytes))
			guard written == Int(nbytes) else {
				ssh_channel_close(channel)
				ssh_channel_free(channel)
				logger.critical("write error")
				logSshGetError()
				return
			}
			nbytes = ssh_channel_read(channel, &buffer, UInt32(MemoryLayout.size(ofValue: Character.self)), 0)
		}

		if nbytes < 0 {
			ssh_channel_close(channel)
			ssh_channel_free(channel)
			logger.critical("didnt read?")
			logSshGetError()
			return
		}
		
		ssh_channel_send_eof(channel)
		ssh_channel_close(channel)
		ssh_channel_free(channel)
		print("testExec succeeded")
	}
	
	func authWithPubkey() {
		var status: CInt
		status = ssh_userauth_publickey_auto(session, nil, nil)
		if status == SSH_AUTH_ERROR.rawValue {
			print("pubkey auth failed")
			logSshGetError()
			fatalError()
		}
	}
	
	func authWithPw(_ username: String, _ password: String) {
		var status: CInt
		status = ssh_userauth_password(session, username, password)
		guard status != SSH_ERROR else {
			print("ssh pw auth error")
			logSshGetError()
			return
		}
	}
	
	func authWithKbInt() {
		var status: CInt
		status = ssh_userauth_kbdint(session, nil, nil)
		while status == SSH_AUTH_INFO.rawValue {
			let name, instruction: String
			var nprompts: CInt
			
			name = UnsafeRawPointer(String(ssh_userauth_kbdint_getname(session)))
			instruction = String(ssh_userauth_kbdint_getinstruction(session))
			nprompts = ssh_userauth_kbdint_getnprompts(session)
			
			if name.count > 0 {
				print(name)
			}
			if instruction.count > 0 {
				print(instruction)
			}
			for promptI in 0..<nprompts {
				let prompt: UnsafePointer<CChar>
				var echo: CChar
				prompt = ssh_userauth_kbdint_getprompt(session, UInt32(promptI), &echo)
				if echo != 0 {
					var buffer: [CChar] = Array(repeating: 0, count: 128)
					var ptr: UnsafeMutablePointer<CChar> = .init(mutating: buffer)
					print(prompt)
					if fgets(&buffer, Int32(MemoryLayout.size(ofValue: buffer)), stdin) == nil {
						fatalError("autherror")
					}
					if (ptr = strchr(buffer, 0)) != nil {
						ptr.pointee = "\0"
					}
					if ssh_userauth_kbdint_setanswer(session, promptI, buffer) < 0 {
						fatalError("autherr")
					}
					memset(&buffer, 0, buffer.count)
				}
			}
		}
	}
	
	func logSshGetError() {
		logger.critical("\(String(describing: ssh_get_error(&self.session)))")
	}
}
