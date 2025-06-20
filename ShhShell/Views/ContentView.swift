//
//  ContentView.swift
//  ShhShell
//
//  Created by neon443 on 02/06/2025.
//

import SwiftUI

struct ContentView: View {
	@ObservedObject var handler: SSHHandler
	@ObservedObject var keyManager: KeyManager
	@ObservedObject var hostsManager: HostsManager
		
    var body: some View {
		TabView {
			HostsView(
				keyManager: keyManager,
				hostsManager: hostsManager
			)
			.tabItem {
				Label("Hosts", systemImage: "server.rack")
			}
			KeyManagerView(keyManager: keyManager)
				.tabItem {
					Label("Keys", systemImage: "key.2.on.ring")
				}
		}
    }
}

#Preview {
    ContentView(
		handler: SSHHandler(host: Host.debug),
		keyManager: KeyManager(),
		hostsManager: HostsManager()
	)
}
