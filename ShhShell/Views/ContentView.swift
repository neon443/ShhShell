//
//  ContentView.swift
//  ShhShell
//
//  Created by neon443 on 02/06/2025.
//

import SwiftUI

struct ContentView: View {
	@ObservedObject var handler: SSHHandler
	@ObservedObject var hostsManager: HostsManager
	@ObservedObject var keyManager: KeyManager
	
	var body: some View {
		NavigationStack {
			ZStack {
				hostsManager.selectedTheme.background.suiColor.opacity(0.7)
					.ignoresSafeArea(.all)
				List {
					SessionsListView(
						handler: handler,
						hostsManager: hostsManager,
						keyManager: keyManager
					)
					
					HostsView(
						handler: handler,
						hostsManager: hostsManager,
						keyManager: keyManager
					)
					
					NavigationLink {
						KeyManagerView(hostsManager: hostsManager, keyManager: keyManager)
					} label: {
						Label("Keys", systemImage: "key.fill")
					}
					
					NavigationLink {
						HostkeysView(hostsManager: hostsManager)
					} label: {
						Label("Hostkey Fingerprints", systemImage: "lock.display")
					}
				}
				.scrollContentBackground(.hidden)
			}
		}
	}
}

#Preview {
    ContentView(
		handler: SSHHandler(host: Host.debug),
		hostsManager: HostsManager(),
		keyManager: KeyManager()
	)
}
