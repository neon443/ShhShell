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
	private var session: ssh_session?
	private var channel: ssh_channel?
	
	@Published var authorized: Bool = false
	
	@Published var host: HostPr
	
	private let userDefaults = NSUbiquitousKeyValueStore.default
	private let logger = Logger(subsystem: "xy", category: "sshHandler")

	init(
		host: HostPr
	) {
		self.host = host
#if DEBUG
		self.host = debugHost()
#endif
	}
	
	func getHostkey() -> Data? {
		var hostkey: ssh_key?
		ssh_get_server_publickey(session, &hostkey)
		
		var hostkeyB64: UnsafeMutablePointer<CChar>? = nil
		
		let status = ssh_pki_export_pubkey_base64(hostkey, &hostkeyB64)
		guard status == SSH_OK else { return nil }
		guard let data = hostkeyB64 else { return nil }
		
		return Data(base64Encoded: String(cString: data))
	}
	
	func connect() -> Bool {
		defer {
			getAuthMethods()
			self.host.key = getHostkey()
		}
		
		var verbosity: Int = 0
		
		session = ssh_new()
		guard session != nil else {
			return false
		}

		ssh_options_set(session, SSH_OPTIONS_HOST, host.address)
		ssh_options_set(session, SSH_OPTIONS_LOG_VERBOSITY, &verbosity)
		ssh_options_set(session, SSH_OPTIONS_PORT, &host.port)

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
		session = nil
		authorized = false
		host.key = nil
	}

	func testExec() -> Bool {
		if ssh_is_connected(session) == 0 {
				return false
		}
		
		guard authorized else { return false }

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
		authorized = true
		return true
	}
	
	func authWithPw() -> Bool {
		var status: CInt
		status = ssh_userauth_password(session, host.username, host.password)
		guard status == SSH_AUTH_SUCCESS.rawValue else {
			print("ssh pw auth error")
			logSshGetError()
			return false
		}
		print("auth success")
		authorized = true
		return true
	}
	
//	func authWithKbInt() -> Bool {
//		var status: CInt
//		status = ssh_userauth_kbdint(session, nil, nil)
//		while status == SSH_AUTH_INFO.rawValue {
//			let name, instruction: String
//			var nprompts: CInt
//			
//			if let namePtr = ssh_userauth_kbdint_getname(session) {
//				name = String(cString: namePtr)
//			} else {
//				return false
//			}
//			if let instrPtr = ssh_userauth_kbdint_getinstruction(session) {
//				instruction = String(cString: instrPtr)
//			} else {
//				return false
//			}
//			nprompts = ssh_userauth_kbdint_getnprompts(session)
//			
//			if name.count > 0 {
//				print(name)
//			}
//			if instruction.count > 0 {
//				print(instruction)
//			}
//			for promptI in 0..<nprompts {
//				let prompt: UnsafePointer<CChar>
//				var echo: CChar = 0
//				prompt = ssh_userauth_kbdint_getprompt(session, UInt32(promptI), &echo)
//				if echo != 0 {
//					var buffer: [CChar] = Array(repeating: 0, count: 128)
//					let ptr: UnsafeMutablePointer<CChar> = .init(mutating: buffer)
//					print(prompt)
//					if fgets(&buffer, Int32(MemoryLayout.size(ofValue: buffer)), stdin) == nil {
//						return false
//					}
//					ptr.pointee = 0//prob fucked
//					if ssh_userauth_kbdint_setanswer(session, UInt32(promptI), buffer) < 0 {
//						return false
//					}
//					memset(&buffer, 0, buffer.count)
//				} else {
//					if (ssh_userauth_kbdint_setanswer(session, UInt32(promptI), &password) != 0) {
//						return false
//					}
//				}
//			}
//			status = ssh_userauth_kbdint(session, nil, nil)
//		}
//		authorized = true
//		return true
//	}
	
	func authWithNone() -> Bool {
		let status = ssh_userauth_none(session, nil)
		guard status == SSH_AUTH_SUCCESS.rawValue else { return false }
		
		print("no security moment lol")
		authorized = true
		return true
	}
	
	func getAuthMethods() {
		var recievedMethod: CInt
		recievedMethod = ssh_userauth_list(session, host.username)
		
		let allAuthDescriptions: [String] = [
			"none",
			"unknown",
			"password",
			"hostbased",
			"publickey",
			"interactive",
			"gssapi_mic"
		]
		let allAuthRaws: [UInt32] = [
			SSH_AUTH_METHOD_NONE,
			SSH_AUTH_METHOD_UNKNOWN,
			SSH_AUTH_METHOD_PASSWORD,
			SSH_AUTH_METHOD_HOSTBASED,
			SSH_AUTH_METHOD_PUBLICKEY,
			SSH_AUTH_METHOD_INTERACTIVE,
			SSH_AUTH_METHOD_GSSAPI_MIC
		]
		let allAuths = zip(allAuthDescriptions, allAuthRaws)
		
		for authMethod in allAuths {
			if authMethod.1 == recievedMethod {
				print(authMethod.0)
			}
		}
		print(recievedMethod)
	}
	
	func openShell() {
		var status: CInt
		
		channel = ssh_channel_new(session)
		guard let channel = channel else { return }
		
		status = ssh_channel_open_session(channel)
		guard status == SSH_OK else {
			ssh_channel_free(channel)
			return
		}
		
		interactiveShellSession()
		
//		ssh_channel_close(channel)
//		ssh_channel_send_eof(channel)
//		ssh_channel_free(channel)
	}
	
	private func interactiveShellSession() {
		var status: CInt
		
		status = ssh_channel_request_pty(channel)
		guard status == SSH_OK else { return }
		
		status = ssh_channel_change_pty_size(channel, 80, 24)
		guard status == SSH_OK else { return }
		
		status = ssh_channel_request_shell(channel)
		guard status == SSH_OK else { return }
		
		while ssh_channel_is_open(channel) != 0 && ssh_channel_is_eof(channel) == 0 {
			var buffer: [CChar] = Array(repeating: 0, count: 256)
			let nbytes = ssh_channel_read_nonblocking(channel, &buffer, UInt32(buffer.count), 0)
			
			guard nbytes > 0 else { return }
			write(1, buffer, Int(nbytes))
			
			let data = Data(bytes: buffer, count: buffer.count)
			print(String(data: data, encoding: .utf8)!)
		}
	}
	
	func readFromChannel() -> String? {
		guard ssh_channel_is_open(channel) != 0 else { return nil }
		guard ssh_channel_is_eof(channel) == 0 else { return nil }
		
		var buffer: [CChar] = Array(repeating: 0, count: 256)
		let nbytes = ssh_channel_read_nonblocking(channel, &buffer, UInt32(buffer.count), 0)
		
		guard nbytes > 0 else { return nil }
		write(1, buffer, Int(nbytes))
		
		let data = Data(bytes: buffer, count: buffer.count)
		return String(data: data, encoding: .utf8)!
	}
	
	private func logSshGetError() {
		logger.critical("\(String(cString: ssh_get_error(&self.session)))")
	}
}
