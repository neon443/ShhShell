//
//  ContentView.swift
//  ShhShell
//
//  Created by neon443 on 02/06/2025.
//

import SwiftUI

struct ContentView: View {
	@ObservedObject var handler: SSHHandler
	@ObservedObject var hostsManger: HostsManager
	@ObservedObject var keyManager: KeyManager
	
    var body: some View {
		TabView {
			HostsView(
				handler: handler,
				hostsManager: hostsManger,
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
		hostsManger: HostsManager(),
		keyManager: KeyManager()
	)
}
