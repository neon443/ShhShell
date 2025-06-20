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
			ConnectionView(
				handler: handler,
				keyManager: keyManager
			)
			.tabItem {
				Label("Connection", systemImage: "powerplug.portrait")
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
		handler: SSHHandler(host: debugHost()),
		keyManager: KeyManager()
	)
}
