//
//  ShhShellApp.swift
//  ShhShell
//
//  Created by neon443 on 02/06/2025.
//

import SwiftUI

@main
struct ShhShellApp: App {
	@StateObject var sshHandler: SSHHandler

	@StateObject var hostsManager: HostsManager = HostsManager()
	@StateObject var keyManager: KeyManager
	
	init() {
		let keyManager = KeyManager()
		_sshHandler = StateObject(wrappedValue: SSHHandler(host: Host.blank, keyManager: keyManager))
		_keyManager = StateObject(wrappedValue: keyManager)
	}
	
	var body: some Scene {
		WindowGroup {
			ContentView(
				handler: sshHandler,
				hostsManager: hostsManager,
				keyManager: keyManager
			)
			.colorScheme(.dark)
			.tint(hostsManager.selectedTheme.ansi[hostsManager.selectedAnsi].suiColor)
		}
	}
}
