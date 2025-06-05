//
//  SSHHandler.swift
//  ShhShell
//
//  Created by neon443 on 05/06/2025.
//

import Foundation
import NMSSH
import LibSSH

class SSHHandler: ObservableObject {
	
	var session: NMSSHSession
	var shellHandlerDelegate = ShellHandler()
	
	
	init(
		session: NMSSHSession = NMSSHSession(host: "localhost:32222", andUsername: "neon443")
	) {
		ssh_new()
		self.session = session
		session.connectToAgent()
	}
	
	func connect() {
		session.authenticate(
			byPublicKey: "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIaFx9u3BMq2qW1SJzQik7k8/9p9KV8KZ9JehyKKd2Wu",
			privateKey: """
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtz
c2gtZWQyNTUxOQAAACCGhcfbtwTKtqltUic0IpO5PP/afSlfCmfSXociindlrgAA
AIgKUk2MClJNjAAAAAtzc2gtZWQyNTUxOQAAACCGhcfbtwTKtqltUic0IpO5PP/a
fSlfCmfSXociindlrgAAAEClrzCbl2ZGxAdqa1rS3w3ZEDKXi7Ysf4FKJO375Lhx
54aFx9u3BMq2qW1SJzQik7k8/9p9KV8KZ9JehyKKd2WuAAAAAAECAwQF
-----END OPENSSH PRIVATE KEY-----
""",
			andPassword: nil
		)
		if session.isConnected {
//			session.authenticate(byPassword: "password")
			do {
				try session.channel.startShell()
			} catch {
				print(error.localizedDescription)
			}
			session.channel.delegate = shellHandlerDelegate
		}
	}
	
	func testExec() {
		guard session.isConnected else { return }
		session.channel.execute("ls", error: nil)
	}
}
