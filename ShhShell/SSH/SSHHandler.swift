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
import SwiftTerm

class SSHHandler: @unchecked Sendable, ObservableObject {
	private var session: ssh_session?
	private var channel: ssh_channel?
	
	var keyManager: KeyManager
	
	@MainActor var container: TerminalViewContainer {
		TerminalViewContainer.shared
	}
	var sessionID: UUID?
	
	var scrollback: [String] = []
//	var scrollbackSize = 0.0
	
	@Published var title: String = ""
	@Published var state: SSHState = .idle
	var connected: Bool {
		return ssh_channel_is_open(channel) == 1 && checkConnected(state)
	}
	
	@Published var testSuceeded: Bool? = nil
	
	@Published var bell: Bool = false
	
	@Published var host: Host
	@Published var hostkeyChanged: Bool = false
	
	private let userDefaults = NSUbiquitousKeyValueStore.default
	private let logger = Logger(subsystem: "xy", category: "sshHandler")
	
	init(host: Host, keyManager: KeyManager?) {
		self.host = host
		self.keyManager = keyManager ?? KeyManager()
	}
	
	func getHostkey() -> String? {
		guard ssh_is_connected(session) == 1 else { return nil }
		
		var hostkey: ssh_key?
		ssh_get_server_publickey(session, &hostkey)
		
		var hostkeyB64: UnsafeMutablePointer<CChar>? = nil
		
		let status = ssh_pki_export_pubkey_base64(hostkey, &hostkeyB64)
		guard status == SSH_OK, let cString = hostkeyB64 else { return nil }
		return String(cString: cString)
	}
	
	func go() {
		guard !connected else { disconnect(); return }
		
		do { try connect() } catch {
			print("error when connecting \(error.localizedDescription)")
			return
		}
		
		checkHostkey(recieved: getHostkey())
		guard hostkeyChanged == false else { return }
		
		do {
			try authWithNone()
		} catch { print("auth with none is not authed") }
		guard state != .authorized else { return }
		
		
		
		for method in getAuthMethods() {
			guard state != .authorized else { break }
			switch method {
			case .password:
				do { try authWithPw() } catch {
					state = .authFailed
					print("pw auth error")
					print(error.localizedDescription)
				}
			case .publickey:
				do { try authWithPubkey() } catch {
					state = .authFailed
					print("error with pubkey auth")
					print(error.localizedDescription)
				}
			case .hostbased:
				disconnect()
			case .interactive:
				disconnect()
			}
		}
		
		ssh_channel_request_env(channel, "TERM", "xterm-256color")
		ssh_channel_request_env(channel, "LANG", "en_US.UTF-8")
		ssh_channel_request_env(channel, "LC_ALL", "en_US.UTF-8")
		
		do { try openShell() } catch {
			print(error.localizedDescription)
		}
		
		setTitle("\(host.username)@\(host.address)")
	}
	
	func connect() throws(SSHError) {
		guard !host.address.isEmpty else { throw .connectionFailed("No address to connect to.") }
		withAnimation { state = .connecting }
		sessionID = UUID()
		
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
		Task { @MainActor in
			self.hostkeyChanged = false
			withAnimation { self.state = .idle }
			withAnimation { self.testSuceeded = nil }
		}
		
		if let sessionID {
			Task { @MainActor in
				container.sessions.removeValue(forKey: sessionID)
				self.sessionID = nil
			}
		}
		scrollback = []
//		scrollbackSize = 0
		
		//send eof if open
		if ssh_channel_is_open(channel) == 1 {
			ssh_channel_send_eof(channel)
		}
		ssh_channel_free(self.channel)
		self.channel = nil
		
		if connected && (ssh_is_connected(session) == 1) {
			ssh_disconnect(self.session)
		}
//		ssh_free(self.session)
		self.session = nil
	}
	
	func checkHostkey(recieved: String?) {
		guard host.key == recieved else {
			self.hostkeyChanged = true
			return
		}
	}
	
	func ring() {
		Task { @MainActor in
			withAnimation(.easeIn(duration: 0.1)) { self.bell = true }
			try? await Task.sleep(nanoseconds: 300_000_000) // 250ms
			withAnimation(.easeOut(duration: 0.1)) { self.bell = false }
		}
	}
	
	func setTitle(_ newTitle: String) {
		Task { @MainActor in
			withAnimation { self.title = newTitle }
		}
	}
	
	func hostInvalid() -> Bool {
		if host.address.isEmpty && host.username.isEmpty {
			return true
		} else {
			return false
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
		guard testChannel != nil else { return }
		
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
	func authWithPubkey() throws(KeyError) {
		guard let keyID = self.host.privateKeyID else { throw .importPrivkeyError }
		guard let keypair = keyManager.keypairs.first(where: { $0.id == keyID }) else {
			throw .importPrivkeyError
		}
		
		var pubkey: ssh_key?
		if ssh_pki_import_pubkey_base64(keypair.base64Pubkey, SSH_KEYTYPE_ED25519, &pubkey) != 0 {
			throw .importPubkeyError
		}
		ssh_userauth_try_publickey(session, nil, pubkey)
		
		var privkey: ssh_key?
		if ssh_pki_import_privkey_base64(keypair.openSshPrivkey, keypair.passphrase, nil, nil, &privkey) != 0 {
			throw .privkeyRejected
		}
		
		if ssh_userauth_publickey(session, nil, privkey) != 0 {
			throw .pubkeyRejected
		}
		state = .authorized
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
	
	//MARK: very wip
//	func authWithKbint() {
//		withAnimation { state = .authorizingKbint }
//		
//		let status = ssh_userauth_kbdint(session, nil, nil)
//		if status == SSH_AUTH_INFO.rawValue {
//			print(ssh_userauth_kbdint_getnprompts(session))
//			print(ssh_userauth_kbdint_getname(session))
//			print(ssh_userauth_kbdint_getinstruction(session))
//			print(ssh_userauth_kbdint_getprompt(session, <#T##i: UInt32##UInt32#>, <#T##echo: UnsafeMutablePointer<CChar>!##UnsafeMutablePointer<CChar>!#>))
//		}
//		
////		for prompt in
//	}
	
	func getAuthMethods() -> [AuthType] {
		var result: [AuthType] = []
		let recievedMethod = UInt32(ssh_userauth_list(session, nil))
		
		for method in AuthType.allCases {
			if (recievedMethod & method.rawValue) != 0 {
				result.append(method)
			}
		}
		return result
	}
	
	//MARK: shell
	func openShell() throws(SSHError) {
		var status: CInt
		
		channel = ssh_channel_new(session)
		guard let channel else { throw .communicationError("Not connected") }
		
		status = ssh_channel_open_session(channel)
		guard status == SSH_OK else {
			ssh_channel_free(channel)
			throw .communicationError("Failed opening channel")
		}
		
		do {
			try interactiveShellSession()
		} catch {
			print(error.localizedDescription)
		}
	}
	
	private func interactiveShellSession() throws(SSHError) {
		var status: CInt
		
		status = ssh_channel_request_pty(self.channel)
		guard status == SSH_OK else { throw .communicationError("PTY request failed") }
		
		status = ssh_channel_change_pty_size(self.channel, 80, 24)
		guard status == SSH_OK else { throw .communicationError("Failed setting PTY size") }
		
		status = ssh_channel_request_shell(self.channel)
		guard status == SSH_OK else { throw .communicationError("Failed requesting shell") }
		
		withAnimation { state = .shellOpen }
	}
	
	func readFromChannel() -> String? {
		guard connected else { return nil }
		guard ssh_channel_is_open(channel) == 1 && ssh_channel_is_eof(channel) == 0 else {
			disconnect()
			return nil
		}
		
		var buffer: [CChar] = Array(repeating: 0, count: 1024)
		let nbytes = ssh_channel_read_nonblocking(channel, &buffer, UInt32(buffer.count), 0)
		
		guard nbytes > 0 else { return nil }
		
		let data = Data(bytes: buffer, count: Int(nbytes))
		if let string = String(data: data, encoding: .utf8) {
			#if DEBUG
//			print(String(data: Data(bytes: buffer, count: Int(nbytes)), encoding: .utf8)!)
			#endif
			Task { @MainActor in
				scrollback.append(string)
//				if scrollbackSize/1024/1024 > 10 {
//					scrollback.remove(at: 0)
//				} else {
//					scrollbackSize += Double(string.lengthOfBytes(using: .utf8))
//				}
			}
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
	
	func resizePTY(toRows: Int, toCols: Int) throws(SSHError) {
		guard ssh_channel_is_open(channel) != 0 else { throw .communicationError("Channel not open") }
		guard ssh_channel_is_eof(channel) == 0 else { throw .backendError("Channel is EOF") }
		
		ssh_channel_change_pty_size(channel, Int32(toCols), Int32(toRows))
//		print("resized tty to \(toRows)rows and \(toCols)cols")
	}
	
//	func prettyScrollbackSize() -> String {
//		if (scrollbackSize/1024/1024) > 1 {
//			return "\(scrollbackSize/1024/1024) MiB scrollback"
//		} else if scrollbackSize/1024 > 1 {
//			return "\(scrollbackSize/1024) KiB scrollback"
//		} else {
//			return "\(scrollbackSize) B scrollback"
//		}
//	}
	
	private func logSshGetError() {
		guard var session = self.session else { return }
		logger.critical("\(String(cString: ssh_get_error(&session)))")
	}
	
	private func logCritical(_ logMessage: String) {
		logger.critical("\(logMessage)")
	}
}
