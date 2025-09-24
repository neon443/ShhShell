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
			ZStack {
				hostsManager.selectedTheme.background.suiColor.opacity(0.7)
					.ignoresSafeArea(.all)
				ContentView(
					handler: sshHandler,
					hostsManager: hostsManager,
					keyManager: keyManager
				)
				.colorScheme(hostsManager.selectedTheme.background.luminance > 0.5 ? .light : .dark)
				.tint(hostsManager.tint)
				if !hostsManager.shownOnboarding {
					WelcomeView(hostsManager: hostsManager)
						.animation(.default, value: hostsManager.shownOnboarding)
						.transition(.opacity)
						.frame(maxWidth: .infinity, maxHeight: .infinity)
						.background(.black)
				}
			}
			.transition(.opacity)
			.animation(.default, value: hostsManager.shownOnboarding)
		}
	}
}
