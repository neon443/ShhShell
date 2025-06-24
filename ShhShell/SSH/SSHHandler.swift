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

class SSHHandler: @unchecked Sendable, ObservableObject {
	private var session: ssh_session?
	private var channel: ssh_channel?
	private let sshQueue = DispatchQueue(label: "SSH Queue")
	
//	@Published var hostsManager = HostsManager()
	
	@Published var connected: Bool = false
	@Published var authorized: Bool = false
	@Published var testSuceeded: Bool? = nil
	
	@Published var bell: UUID?
	
	@Published var host: Host
	
	private let userDefaults = NSUbiquitousKeyValueStore.default
	private let logger = Logger(subsystem: "xy", category: "sshHandler")
	
	init(
		host: Host
//		hostsManager: HostsManager
	) {
		self.host = host
//		self.hostsManager = hostsManager
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
	
	func go() {
		guard !connected else {
			Task {
				await disconnect()
			}
			return
		}
		
		guard let _ = try? connect() else { return }
		
		
		
		if !host.password.isEmpty {
			do { try authWithPw() } catch {
				print("pw auth error")
			}
		} else {
			do {
				if let publicKey = host.publicKey,
				   let privateKey = host.privateKey {
					try authWithPubkey(pub: publicKey, priv: privateKey, pass: host.passphrase)
				}
			} catch {
				print("error with pubkey auth")
			}
		}
		openShell()
		ssh_channel_request_env(channel, "TERM", "xterm-256color")
		ssh_channel_request_env(channel, "LANG", "en_US.UTF-8")
		ssh_channel_request_env(channel, "LC_ALL", "en_US.UTF-8")
	}
	
	func connect() throws(SSHError) {
		defer {
			getAuthMethods()
			self.host.key = getHostkey()
		}
		
		var verbosity: Int = 0
//		var verbosity: Int = SSH_LOG_FUNCTIONS
		
		session = ssh_new()
		guard session != nil else {
			withAnimation { connected = false }
			throw .backendError("Failed opening session")
		}

		ssh_options_set(session, SSH_OPTIONS_HOST, host.address)
		ssh_options_set(session, SSH_OPTIONS_LOG_VERBOSITY, &verbosity)
		ssh_options_set(session, SSH_OPTIONS_PORT, &host.port)
		ssh_options_set(session, SSH_OPTIONS_USER, host.username)

		let status = ssh_connect(session)
		if status != SSH_OK {
			logger.critical("connection not ok: \(status)")
			logSshGetError()
			withAnimation { connected = false }
			throw .connectionFailed("Failed connecting")
		}
		withAnimation { connected = true }
		return
	}

	func disconnect() async {
		await MainActor.run {
			withAnimation { connected = false }
			withAnimation { authorized = false }
			withAnimation { testSuceeded = nil }
		}
		
		ssh_channel_send_eof(self.channel)
		ssh_channel_free(self.channel)
		self.channel = nil
		
		ssh_disconnect(self.session)
		ssh_free(self.session)
		self.session = nil
	}
	
	func checkHostkey() {
		
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
			UInt32(buffer.count),
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
			nbytes = ssh_channel_read(channel, &buffer, UInt32(buffer.count), 0)
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
	
	func authWithPubkey(pub pubInp: Data, priv privInp: Data, pass: String) throws(KeyError) {
		guard session != nil else {
			withAnimation { authorized = false }
			return
		}
		
		let fileManager = FileManager.default
		let tempDir = fileManager.temporaryDirectory
		let tempPubkey = tempDir.appendingPathComponent("key.pub")
		let tempKey = tempDir.appendingPathComponent("key")
		
		fileManager.createFile(atPath: tempPubkey.path(), contents: nil)
		fileManager.createFile(atPath: tempKey.path(), contents: nil)
		
		try? pubInp.write(to: tempPubkey, options: .completeFileProtection)
		try? privInp.write(to: tempKey, options: .completeFileProtection)
		
		let attributes: [FileAttributeKey: Any] = [.posixPermissions: 0o600]
		do {
			try fileManager.setAttributes(attributes, ofItemAtPath: tempPubkey.path())
			try fileManager.setAttributes(attributes, ofItemAtPath: tempKey.path())
		} catch {
			logCritical("permission settig failed\(error.localizedDescription)")
		}
		
		var pubkey: ssh_key?
		if ssh_pki_import_pubkey_file(tempPubkey.path(), &pubkey) != 0 {
			throw .importPrivkeyError
		}
		
		if ssh_userauth_try_publickey(session, nil, pubkey) != 0 {
			throw .pubkeyRejected
		}
		
		var privkey: ssh_key?
		if ssh_pki_import_privkey_file(tempKey.path(), pass, nil, nil, &privkey) != 0 {
			throw .importPrivkeyError
		}
		
		if (ssh_userauth_publickey(session, nil, privkey) != 0) {
			withAnimation { authorized = false }
			throw .privkeyRejected
		}
		
		//if u got this far, youre authed!
		withAnimation { authorized = true }
		
		ssh_key_free(pubkey)
		ssh_key_free(privkey)
		try? FileManager.default.removeItem(at: tempPubkey)
		try? FileManager.default.removeItem(at: tempKey)
		return
	}
	
	func authWithPw() throws(AuthError) {
		var status: CInt
		status = ssh_userauth_password(session, host.username, host.password)
		guard status == SSH_AUTH_SUCCESS.rawValue else {
			logSshGetError()
			throw .rejectedCredentials
		}
		withAnimation { authorized = true }
		return
	}
	
	func authWithNone() throws(AuthError) {
		let status = ssh_userauth_none(session, nil)
		guard status == SSH_AUTH_SUCCESS.rawValue else { throw .rejectedCredentials }
		
		logCritical("no security moment lol")
		withAnimation { authorized = true }
		return
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
	}
	
	private func interactiveShellSession() {
		var status: CInt
		
		status = ssh_channel_request_pty(self.channel)
		guard status == SSH_OK else { return }
		
		status = ssh_channel_change_pty_size(self.channel, 80, 24)
		guard status == SSH_OK else { return }
		
		status = ssh_channel_request_shell(self.channel)
		guard status == SSH_OK else { return }
		
		
	}
	
	func readFromChannel() -> String? {
		guard connected else { return nil }
		guard ssh_channel_is_open(channel) != 0 || ssh_channel_is_eof(channel) == 0 else {
			Task { await disconnect() }
			return nil
		}
		
		var buffer: [CChar] = Array(repeating: 0, count: 4096)
		let nbytes = ssh_channel_read_nonblocking(channel, &buffer, UInt32(buffer.count), 0)
		
		guard nbytes > 0 else { return nil }
		
		let data = Data(bytes: buffer, count: Int(nbytes))
		if let string = String(data: data, encoding: .utf8) {
			#if DEBUG
			print(String(data: Data(bytes: buffer, count: Int(nbytes)), encoding: .utf8)!)
			#endif
			return string
		}
		return nil
	}
	
	private func logSshGetError() {
		logger.critical("\(String(cString: ssh_get_error(&self.session)))")
	}
	
	private func logCritical(_ logMessage: String) {
		logger.critical("\(logMessage)")
	}
	
	func writeToChannel(_ string: String?) {
		guard let string = string else { return }
		guard channel != nil else { return }
		guard ssh_channel_is_open(channel) != 0 else { return }
		guard ssh_channel_is_eof(channel) == 0 else { return }
		
		var buffer: [CChar] = []
		for byte in string.utf8 {
			buffer.append(CChar(bitPattern: byte))
		}
		let nwritten = Int(ssh_channel_write(channel, &buffer, UInt32(buffer.count)))
		
		if nwritten != buffer.count {
			print("partial write!!")
		}
	}
	
	func resizePTY(toRows: Int, toCols: Int) {
		guard ssh_channel_is_open(channel) != 0 else { return }
		guard ssh_channel_is_eof(channel) == 0 else { return }
		
		ssh_channel_change_pty_size(channel, Int32(toCols), Int32(toRows))
//		print("resized tty to \(toRows)rows and \(toCols)cols")
	}
}
