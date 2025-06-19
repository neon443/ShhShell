//
//  SSHHandler.swift
//  ShhShell
//
//  Created by neon443 on 05/06/2025.
//

import Foundation
import LibSSH
import OSLog
import SwiftUI

class SSHHandler: ObservableObject {
	private var session: ssh_session?
	private var channel: ssh_channel?
	private var readTimer: Timer?
	
	@Published var connected: Bool = false
	@Published var authorized: Bool = false
	@Published var testSuceeded: Bool = false
	
	@Published var host: HostPr
	@Published var terminal: String = ""
	
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
	
//	func connect(_: Host) {
//		
//	}
	
	func connect() {
		defer {
			getAuthMethods()
			self.host.key = getHostkey()
		}
		
		var verbosity: Int = SSH_LOG_FUNCTIONS
		
		session = ssh_new()
		guard session != nil else {
			withAnimation { connected = false }
			return
		}

		ssh_options_set(session, SSH_OPTIONS_HOST, host.address)
		ssh_options_set(session, SSH_OPTIONS_LOG_VERBOSITY, &verbosity)
		ssh_options_set(session, SSH_OPTIONS_PORT, &host.port)

		let status = ssh_connect(session)
		if status != SSH_OK {
			logger.critical("connection not ok: \(status)")
			logSshGetError()
			withAnimation { connected = false }
			return
		}
		withAnimation { connected = true }
		return
	}

	func disconnect() {
		guard session != nil else {
			print("cant disconnect when im not connected")
			return
		}
		ssh_disconnect(session)
		ssh_free(session)
		session = nil
		withAnimation { authorized = false }
		withAnimation { connected = false }
		host.key = nil
	}

	func testExec() {
		if ssh_is_connected(session) == 0 {
			withAnimation { testSuceeded = false }
			return
		}
		
		guard authorized else {
			withAnimation { testSuceeded = false }
			return
		}

		var status: CInt
		var buffer: [Int] = Array(repeating: 0, count: 256)
		var nbytes: CInt

		let channel = ssh_channel_new(session)
		guard channel != nil else {
			withAnimation { testSuceeded = false }
			return
		}

		status = ssh_channel_open_session(channel)
		guard status == SSH_OK else {
			ssh_channel_free(channel)
			logger.critical("session opening error")
			logSshGetError()
			withAnimation { testSuceeded = false }
			return
		}

		status = ssh_channel_request_exec(channel, "uptime")
		guard status == SSH_OK else {
			ssh_channel_close(channel)
			ssh_channel_free(channel)
			logger.critical("session opening error")
			logSshGetError()
			withAnimation { testSuceeded = false }
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
				withAnimation { testSuceeded = false }
				return
			}
			nbytes = ssh_channel_read(channel, &buffer, UInt32(MemoryLayout.size(ofValue: Character.self)), 0)
		}

		if nbytes < 0 {
			ssh_channel_close(channel)
			ssh_channel_free(channel)
			logger.critical("didnt read?")
			logSshGetError()
			withAnimation { testSuceeded = false }
			return
		}
		
		ssh_channel_send_eof(channel)
		ssh_channel_close(channel)
		ssh_channel_free(channel)
		print("testExec succeeded")
		withAnimation { testSuceeded = true }
		return
	}
	
	func authWithPubkey(pub: Data, priv: Data, pass: String) {
		guard session != nil else {
			withAnimation { authorized = false }
			return
		}
		
		var status: Int32
		let fileManager = FileManager.default
		let tempDir = fileManager.temporaryDirectory
		let tempPubkey = tempDir.appendingPathComponent("key.pub")
		let tempKey = tempDir.appendingPathComponent("key")
		
		fileManager.createFile(atPath: tempPubkey.path(), contents: nil)
		fileManager.createFile(atPath: tempKey.path(), contents: nil)
		
		try? pub.write(to: tempPubkey)
		try? priv.write(to: tempKey)
		
		var pubkey: ssh_key?
		ssh_pki_import_pubkey_file(tempPubkey.path(), &pubkey)
		status = ssh_userauth_try_publickey(session, nil, pubkey)
		print(status)
		
		var privkey: ssh_key?
		if ssh_pki_import_privkey_file(tempKey.path(), pass, nil, nil, &privkey) != 0 {
			print("help?!?")
			print("likeley password is incorrect")
		}
		
		status = ssh_userauth_publickey(session, nil, privkey)
		if status != 0 {
			withAnimation { authorized = false }
			print("auth failed lol")
			return
		}
		
		withAnimation { authorized = true }
		return
		//if u got this far, youre authed!
		//cleanpu here:
//		ssh_key_free(pubkey)
//		ssh_key_free(privkey)
//		try? fileManager.removeItem(at: tempPubkey)
//		try? fileManager.removeItem(at: tempKey)
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
		withAnimation { authorized = true }
		return true
	}
	
	func authWithNone() -> Bool {
		let status = ssh_userauth_none(session, nil)
		guard status == SSH_AUTH_SUCCESS.rawValue else { return false }
		
		print("no security moment lol")
		withAnimation { authorized = true }
		return true
	}
	
	//always unknown idk why
	func getAuthMethods() {
		var recievedMethod: CInt
		recievedMethod = ssh_userauth_list(session, nil)
		
		let allAuthDescriptions: [String] = [
			"password",
			"publickey",
			"hostbased",
			"interactive"
		]
		let allAuthRaws: [UInt32] = [
			SSH_AUTH_METHOD_PASSWORD,
			SSH_AUTH_METHOD_PUBLICKEY,
			SSH_AUTH_METHOD_HOSTBASED,
			SSH_AUTH_METHOD_INTERACTIVE
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
		
		status = ssh_channel_request_pty(self.channel)
		guard status == SSH_OK else { return }
		
		status = ssh_channel_change_pty_size(self.channel, 80, 24)
		guard status == SSH_OK else { return }
		
		status = ssh_channel_request_shell(self.channel)
		guard status == SSH_OK else { return }
		
		self.readTimer = Timer(timeInterval: 0.1, repeats: true) { timer in
			guard ssh_channel_is_open(self.channel) != 0 else {
				timer.invalidate()
				self.readTimer = nil
				return
			}
			guard ssh_channel_is_eof(self.channel) == 0 else {
				timer.invalidate()
				self.readTimer = nil
				return
			}
			self.readFromChannel()
		}
		RunLoop.main.add(self.readTimer!, forMode: .common)
	}
	
	func readFromChannel() {
		guard ssh_channel_is_open(channel) != 0 else { return }
		guard ssh_channel_is_eof(channel) == 0 else { return }
		
		var buffer: [CChar] = Array(repeating: 0, count: 256)
		let nbytes = ssh_channel_read_nonblocking(channel, &buffer, UInt32(buffer.count), 0)
		
		guard nbytes > 0 else { return }
		write(1, buffer, Int(nbytes))
		
		let data = Data(bytes: buffer, count: buffer.count)
		self.terminal.append(String(data: data, encoding: .utf8)!)
	}
	
	private func logSshGetError() {
		logger.critical("\(String(cString: ssh_get_error(&self.session)))")
	}
	
	func writeToChannel() {
		guard ssh_channel_is_open(channel) != 0 else { return }
		guard ssh_channel_is_eof(channel) == 0 else { return }
		
		var buffer: [CChar] = Array(repeating: 65, count: 256)
		var nbytes: Int
		var nwritten: Int
		
//		readFromChannel()
		nbytes = Int(read(0, &buffer, buffer.count))
		nbytes = buffer.count
		guard nbytes > 0 else {
			return
		}
		if nbytes > 0 {
			nwritten = Int(ssh_channel_write(channel, &buffer, UInt32(nbytes)))
			guard nwritten == nbytes else { return }
		}
//		readFromChannel()
	}
}
