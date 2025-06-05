//
//  SSHHandler.swift
//  ShhShell
//
//  Created by neon443 on 05/06/2025.
//

import Foundation
//import NMSSH
import LibSSH

class SSHHandler: ObservableObject {
	var session: ssh_session?
	var shellHandlerDelegate = ShellHandler()
	
	init() {
//		session = ssh_new()
//		guard session != nil else { return }
	}
	
	func connect() {
		var verbosity: Int = SSH_LOG_PROTOCOL
		var port: Int = 2222
		
		session = ssh_new()
		guard session != nil else {
			fatalError("no ssh session??!?!")
		}
		
		ssh_options_set(session, SSH_OPTIONS_HOST, "localhost")
		ssh_options_set(session, SSH_OPTIONS_LOG_VERBOSITY, &verbosity)
		ssh_options_set(session, SSH_OPTIONS_PORT, &port)
		
		let status = ssh_connect(session)
		print(status)
	}
	
	func disconnect() {
		guard session != nil else { fatalError("no ssession") }
		ssh_disconnect(session)
	}
	
	func hardcodedAuth() {
		var hostkey: ssh_key?
		ssh_get_server_publickey(session, &hostkey)
		print(hostkey)
		
		var password = "root"
		
		let rc = ssh_userauth_password(session, "root", password)
		if rc != SSH_AUTH_SUCCESS.rawValue {
			print("auth failure")
		} else {
			print("yay success")
		}
	}
	
	func testExec() {
		connect()
		hardcodedAuth()
		disconnect()
	}
}
