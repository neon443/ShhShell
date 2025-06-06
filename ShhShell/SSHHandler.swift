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
	
	@Published var username: String
	@Published var password: String
	@Published var address: String
	@Published var port: Int

	private let logger = Logger(subsystem: "xy", category: "sshHandler")

	init(
		username: String = "",
		password: String = "",
		address: String = "",
		port: Int = 22
	) {
		#if DEBUG
		self.username = "root"
		self.password = "root"
		self.address = "localhost"
		self.port = 2222
		#endif
		self.username = username
		self.password = password
		self.address = address
		self.port = port
	}
	
	func getHostkey() {
		var hostkey: ssh_key?
		ssh_get_server_publickey(session, &hostkey)
		
		var hostkeyB64: UnsafeMutablePointer<CChar>? = nil
		if ssh_pki_export_pubkey_base64(hostkey, &hostkeyB64) == SSH_OK {
			if let hostkeyB64 = hostkeyB64 {
				print(String(cString: hostkeyB64))
			}
		}
	}
	
	func connect() -> Bool {
		defer {
			getHostkey()
			getAuthMethods()
		}
		
		var verbosity: Int = 0
		
		session = ssh_new()
		guard session != nil else {
			return false
		}

		ssh_options_set(session, SSH_OPTIONS_HOST, address)
		ssh_options_set(session, SSH_OPTIONS_LOG_VERBOSITY, &verbosity)
		ssh_options_set(session, SSH_OPTIONS_PORT, &port)

		let status = ssh_connect(session)
		if status != SSH_OK {
			logger.critical("connection not ok: \(status)")
			logSshGetError()
			return false
		}
		return true
	}

	func disconnect() {
		guard session != nil else {
			print("cant disconnect when im not connected")
			return
		}
		ssh_disconnect(session)
		ssh_free(session)
	}

	func testExec() -> Bool {
		if ssh_is_connected(session) == 0 {
			if !connect() {
				return false
			}
		}
		
		guard authWithPw() else { return false }

		var status: CInt
		var buffer: [Int] = Array(repeating: 0, count: 256)
		var nbytes: CInt

		let channel = ssh_channel_new(session)
		guard channel != nil else { return false }

		status = ssh_channel_open_session(channel)
		guard status == SSH_OK else {
			ssh_channel_free(channel)
			logger.critical("session opening error")
			logSshGetError()
			return false
		}

		status = ssh_channel_request_exec(channel, "uptime")
		guard status == SSH_OK else {
			ssh_channel_close(channel)
			ssh_channel_free(channel)
			logger.critical("session opening error")
			logSshGetError()
			return false
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
				return false
			}
			nbytes = ssh_channel_read(channel, &buffer, UInt32(MemoryLayout.size(ofValue: Character.self)), 0)
		}

		if nbytes < 0 {
			ssh_channel_close(channel)
			ssh_channel_free(channel)
			logger.critical("didnt read?")
			logSshGetError()
			return false
		}
		
		ssh_channel_send_eof(channel)
		ssh_channel_close(channel)
		ssh_channel_free(channel)
		print("testExec succeeded")
		return true
	}
	
	func authWithPubkey() -> Bool {
		var status: CInt
		status = ssh_userauth_publickey_auto(session, nil, nil)
		if status == SSH_AUTH_ERROR.rawValue {
			print("pubkey auth failed")
			logSshGetError()
			return false
		}
		return true
	}
	
	func authWithPw() -> Bool {
		var status: CInt
		status = ssh_userauth_password(session, username, password)
		guard status != SSH_AUTH_SUCCESS.rawValue else {
			print("ssh pw auth error")
			logSshGetError()
			return false
		}
		print("auth success")
		return true
	}
	
	func authWithKbInt() -> Bool {
		var status: CInt
		status = ssh_userauth_kbdint(session, nil, nil)
		while status == SSH_AUTH_INFO.rawValue {
			let name, instruction: String
			var nprompts: CInt
			
			if let namePtr = ssh_userauth_kbdint_getname(session) {
				name = String(cString: namePtr)
			} else {
				return false
			}
			if let instrPtr = ssh_userauth_kbdint_getinstruction(session) {
				instruction = String(cString: instrPtr)
			} else {
				return false
			}
			nprompts = ssh_userauth_kbdint_getnprompts(session)
			
			if name.count > 0 {
				print(name)
			}
			if instruction.count > 0 {
				print(instruction)
			}
			for promptI in 0..<nprompts {
				let prompt: UnsafePointer<CChar>
				var echo: CChar = 0
				prompt = ssh_userauth_kbdint_getprompt(session, UInt32(promptI), &echo)
				if echo != 0 {
					var buffer: [CChar] = Array(repeating: 0, count: 128)
					let ptr: UnsafeMutablePointer<CChar> = .init(mutating: buffer)
					print(prompt)
					if fgets(&buffer, Int32(MemoryLayout.size(ofValue: buffer)), stdin) == nil {
						return false
					}
					ptr.pointee = 0//prob fucked
					if ssh_userauth_kbdint_setanswer(session, UInt32(promptI), buffer) < 0 {
						return false
					}
					memset(&buffer, 0, buffer.count)
				} else {
					if (ssh_userauth_kbdint_setanswer(session, UInt32(promptI), &password) != 0) {
						return false
					}
				}
			}
			status = ssh_userauth_kbdint(session, nil, nil)
		}
		return true
	}
	
	func authWithNone() -> Bool {
		let status = ssh_userauth_none(session, nil)
		if status == SSH_AUTH_SUCCESS.rawValue {
			print("no security moment lol")
			return true
		} else {
			return false
		}
	}
	
	func getAuthMethods() {
		var method: CInt
		method = ssh_userauth_list(session, username)
	}
	
	func logSshGetError() {
		logger.critical("\(String(cString: ssh_get_error(&self.session)))")
	}
}
