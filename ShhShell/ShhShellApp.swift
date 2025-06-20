//
//  ShhShellApp.swift
//  ShhShell
//
//  Created by neon443 on 02/06/2025.
//

import SwiftUI

@main
struct ShhShellApp: App {
	@StateObject var sshHandler: SSHHandler = SSHHandler(host: Host.blank)
	@StateObject var keyManager: KeyManager = KeyManager()
	@StateObject var hostsManager: HostsManager = HostsManager()
	
	var body: some Scene {
		WindowGroup {
			ContentView(
				handler: sshHandler,
				keyManager: keyManager,
				hostsManager: hostsManager
			)
		}
	}
}
