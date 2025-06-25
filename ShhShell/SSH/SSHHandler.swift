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
	
	@Published var title: String = ""
	@Published var state: SSHState = .idle
	var connected: Bool {
		return checkConnected(state)
	}
	
	@Published var testSuceeded: Bool? = nil
	
	@Published var bell: UUID? = nil
	
	@Published var host: Host
	
	private let userDefaults = NSUbiquitousKeyValueStore.default
	private let logger = Logger(subsystem: "xy", category: "sshHandler")
	
	init(host: Host) {
		self.host = host
	}
	
	func getHostkey() -> Data? {
		var hostkey: ssh_key?
		ssh_get_server_publickey(session, &hostkey)
		
		var hostkeyB64: UnsafeMutablePointer<CChar>? = nil
		
		let status = ssh_pki_export_pubkey_base64(hostkey, &hostkeyB64)
		guard status == SSH_OK, let cString = hostkeyB64 else { return nil }
		return String(cString: cString).data(using: .utf8)
	}
	
	func go() {
		guard !connected else {
			withAnimation { state = .idle }
			disconnect()
			return
		}
		
		do {
			try connect()
		} catch {
			print("error in connect \(error.localizedDescription)")
		}
		guard connected else { return }
		
		try? authWithNone()
		getAuthMethods()
		self.host.key = getHostkey()
		
		if !host.password.isEmpty {
			do { try authWithPw() } catch {
				print("pw auth error")
				print(error.localizedDescription)
			}
		} else {
			do {
				if let publicKey = host.publicKey,
				   let privateKey = host.privateKey {
					try authWithPubkey(pub: publicKey, priv: privateKey, pass: host.passphrase)
				}
			} catch {
				print("error with pubkey auth")
				print(error.localizedDescription)
			}
		}
		openShell()
		setTitle("\(host.username)@\(host.address)")
		ssh_channel_request_env(channel, "TERM", "xterm-256color")
		ssh_channel_request_env(channel, "LANG", "en_US.UTF-8")
		ssh_channel_request_env(channel, "LC_ALL", "en_US.UTF-8")
	}
	
	func connect() throws(SSHError) {
		withAnimation { state = .connecting }
		
		var verbosity: Int = 0
//		var verbosity: Int = SSH_LOG_FUNCTIONS
		
		session = ssh_new()
		guard session != nil else {
			withAnimation { state = .idle }
			throw .backendError("Failed opening session")
		}
		
		ssh_options_set(session, SSH_OPTIONS_HOST, host.address)
		ssh_options_set(session, SSH_OPTIONS_LOG_VERBOSITY, &verbosity)
		ssh_options_set(session, SSH_OPTIONS_PORT, &host.port)
		ssh_options_set(session, SSH_OPTIONS_USER, host.username)
		
		let status = ssh_connect(session)
		if status != SSH_OK {
			ssh_free(session)
			logger.critical("connection not ok: \(status)")
			logSshGetError()
			withAnimation { state = .idle }
			throw .connectionFailed("Failed connecting")
		}
		withAnimation { state = .authorizing }
		return
	}
	
	func disconnect() {
		withAnimation { self.state = .idle }
		withAnimation { self.testSuceeded = nil }
		
		//send eof if open
		if ssh_channel_is_open(channel) == 1 {
			ssh_channel_send_eof(channel)
		}
		ssh_channel_free(self.channel)
		self.channel = nil
		
		if connected && (ssh_is_connected(session) == 1) {
			ssh_disconnect(self.session)
		}
		ssh_free(self.session)
		self.session = nil
	}
	
	func checkHostkey() {
		
	}
	
	func ring() {
		withAnimation { bell = UUID() }
		DispatchQueue.main.asyncAfter(deadline: .now()+1) {
			withAnimation { self.bell = nil }
		}
	}
	
	func setTitle(_ newTitle: String) {
		DispatchQueue.main.async {
			self.title = newTitle
		}
	}
	
	func testExec() {
		var success = false
		defer {
			disconnect()
			withAnimation { testSuceeded = success }
		}
		
		if !checkAuth(state) {
			go()
		}
		guard checkAuth(state) else { return }
		
		if ssh_is_connected(session) == 0 { return }
		
		guard checkAuth(state) else { return }
		
		var status: CInt
		var buffer: [CChar] = Array(repeating: 0, count: 256)
		var nbytes: CInt
		
		let testChannel = ssh_channel_new(session)
		guard testChannel != nil else {
			return
		}
		
		status = ssh_channel_open_session(testChannel)
		guard status == SSH_OK else {
			ssh_channel_free(testChannel)
			logger.critical("session opening error")
			logSshGetError()
			return
		}
		
		status = ssh_channel_request_exec(testChannel, "uptime")
		guard status == SSH_OK else {
			ssh_channel_close(testChannel)
			ssh_channel_free(testChannel)
			logger.critical("session opening error")
			logSshGetError()
			return
		}
		
		nbytes = ssh_channel_read_nonblocking(
			testChannel,
			&buffer,
			UInt32(buffer.count),
			0
		)
		
		if nbytes < 0 {
			ssh_channel_close(testChannel)
			ssh_channel_free(testChannel)
			logger.critical("didnt read?")
			logSshGetError()
			return
		}
		
		ssh_channel_send_eof(testChannel)
		ssh_channel_close(testChannel)
		ssh_channel_free(testChannel)
		print("testExec succeeded")
		success = true
		return
	}
	
	//MARK: auth
	func authWithPubkey(pub pubInp: Data, priv privInp: Data, pass: String) throws(KeyError) {
		guard session != nil else {
			return
		}
		
		let fileManager = FileManager.default
		let tempDir = fileManager.temporaryDirectory
		let tempPubkey = tempDir.appendingPathComponent("\(UUID())key.pub")
		let tempKey = tempDir.appendingPathComponent("\(UUID())key")
		
		fileManager.createFile(atPath: tempPubkey.path(), contents: nil)
		fileManager.createFile(atPath: tempKey.path(), contents: nil)
		
		do {
			try pubInp.write(to: tempPubkey, options: .completeFileProtection)
			try privInp.write(to: tempKey, options: .completeFileProtection)
		} catch {
			print("file writing error")
			print(error.localizedDescription)
		}
		
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
		defer { ssh_key_free(pubkey) }
		
		if ssh_userauth_try_publickey(session, nil, pubkey) != 0 {
			throw .pubkeyRejected
		}
		
		var privkey: ssh_key?
		if ssh_pki_import_privkey_file(tempKey.path(), pass, nil, nil, &privkey) != 0 {
			throw .importPrivkeyError
		}
		defer { ssh_key_free(privkey) }
		
		if (ssh_userauth_publickey(session, nil, privkey) != 0) {
			throw .privkeyRejected
		}
		
		//if u got this far, youre authed!
		withAnimation { state = .authorized }
		
		do {
			try FileManager.default.removeItem(at: tempPubkey)
			try FileManager.default.removeItem(at: tempKey)
		} catch {
			print("error removing file")
			print(error.localizedDescription)
		}
		return
	}
	
	func authWithPw() throws(AuthError) {
		var status: CInt
		status = ssh_userauth_password(session, host.username, host.password)
		guard status == SSH_AUTH_SUCCESS.rawValue else {
			logSshGetError()
			throw .rejectedCredentials
		}
		withAnimation { state = .authorized }
		return
	}
	
	func authWithNone() throws(AuthError) {
		let status = ssh_userauth_none(session, nil)
		guard status == SSH_AUTH_SUCCESS.rawValue else { throw .rejectedCredentials }
		
		logCritical("no security moment lol")
		withAnimation { state = .authorized }
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
			if (recievedMethod & Int32(authMethod.1)) != 0 {
				print(authMethod.0)
			}
		}
	}
	
	//MARK: shell
	func openShell() {
		var status: CInt
		
		channel = ssh_channel_new(session)
		guard let channel else { return }
		
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
		
		withAnimation { state = .shellOpen }
	}
	
	func readFromChannel() -> String? {
		guard connected else { return nil }
		guard ssh_channel_is_open(channel) == 1 && ssh_channel_is_eof(channel) == 0 else {
			disconnect()
			return nil
		}
		
		var buffer: [CChar] = Array(repeating: 0, count: 16_384)
		let nbytes = ssh_channel_read_nonblocking(channel, &buffer, UInt32(buffer.count), 0)
		
		guard nbytes > 0 else { return nil }
		
		let data = Data(bytes: buffer, count: Int(nbytes))
		if let string = String(data: data, encoding: .utf8) {
			#if DEBUG
//			print(String(data: Data(bytes: buffer, count: Int(nbytes)), encoding: .utf8)!)
			#endif
			return string
		}
		return nil
	}
	
	func writeToChannel(_ string: String?) {
		guard let string else { return }
		guard ssh_channel_is_open(channel) == 1 && ssh_channel_is_eof(channel) == 0 else {
			Task { disconnect() }
			return
		}
		
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
	
	private func logSshGetError() {
		guard var session = self.session else { return }
		logger.critical("\(String(cString: ssh_get_error(&session)))")
	}
	
	private func logCritical(_ logMessage: String) {
		logger.critical("\(logMessage)")
	}
}
