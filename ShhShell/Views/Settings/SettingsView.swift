//
//  SettingsView.swift
//  ShhShell
//
//  Created by neon443 on 19/08/2025.
//

import SwiftUI

struct SettingsView: View {
	@ObservedObject var hostsManager: HostsManager
	@ObservedObject var keyManager: KeyManager
	
    var body: some View {
		ZStack {
			hostsManager.selectedTheme.background.suiColor.opacity(0.7)
				.ignoresSafeArea(.all)
			List {
				Section("Terminal") {
					Label("Scrollback", systemImage: "scroll")
					HStack {
						Slider(value: .constant(0), in: 1_000...50_000, step: 1_000)
						Text("\()")
					}
				}
			}
			.listStyle(.sidebar)
			.scrollContentBackground(.hidden)
		}
    }
}

#Preview {
	SettingsView(
		hostsManager: HostsManager(),
		keyManager: KeyManager()
	)
}
