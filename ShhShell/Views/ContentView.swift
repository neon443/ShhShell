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
	
    var body: some View {
		TabView {
			HostsView(
				handler: handler,
				keyManager: keyManager
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
		keyManager: KeyManager()
	)
}
