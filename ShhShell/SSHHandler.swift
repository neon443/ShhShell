//
//  SSHHandler.swift
//  ShhShell
//
//  Created by neon443 on 05/06/2025.
//

import Foundation
import LibSSH

class SSHHandler: ObservableObject {
	var session: ssh_session?
	
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
		print(status)
	}
	
	func disconnect() {
		guard session != nil else { fatalError("no ssession") }
		ssh_disconnect(session)
	}
	
	func hardcodedAuth() {
		var hostkey: ssh_key?
		ssh_get_server_publickey(session, &hostkey)
		print("hostkey \(hostkey)")
		
		let password = "root"
		
		let rc = ssh_userauth_password(session, "root", password)
		if rc != SSH_AUTH_SUCCESS.rawValue {
			print("auth failure")
		} else {
			print("yay success")
		}
	}
	
	func testExec() {
		connect()
		defer { disconnect();ssh_free(session) }
		
		hardcodedAuth()
		
		var channel: ssh_channel?
		var rc: Int32
		var buffer: [CChar] = Array(repeating: 0, count: 256)
		var nbytes: Int32
		
		channel = ssh_channel_new(session)
		if channel == nil {
			fatalError("couldnt create channel \(SSH_ERROR)")
		}
		
		rc = ssh_channel_open_session(channel)
		if rc != SSH_OK {
			ssh_channel_free(channel)
			print("channel opened \(rc)")
		}
		
		rc = ssh_channel_request_exec(channel, "uptime")
		if rc != SSH_OK {
			ssh_channel_close(channel)
			ssh_channel_free(channel)
			print("exec request worked \(rc)")
		}
		
		nbytes = ssh_channel_read(channel, &buffer, UInt32(buffer.count), 0)
		while nbytes > 0 {
			let written = write(1, buffer, Int(nbytes))
			if written != Int(nbytes) {
				ssh_channel_close(channel)
				ssh_channel_free(channel)
				fatalError("buffer write error \(SSH_ERROR)")
			}
			buffer = [CChar](repeating: 0, count: 256) //clear buffer
			nbytes = ssh_channel_read(channel, &buffer, UInt32(buffer.count), 0)
		}
		
		if nbytes < 0 {
			ssh_channel_close(channel)
			ssh_channel_free(channel)
			fatalError("\(SSH_ERROR)")
		}
		
		ssh_channel_send_eof(channel)
		ssh_channel_close(channel)
		ssh_channel_free(channel)
		
		print("sshNoOk? \(SSH_OK)")
	}
}
