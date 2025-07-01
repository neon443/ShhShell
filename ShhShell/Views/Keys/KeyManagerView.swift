//
//  KeyManagerView.swift
//  ShhShell
//
//  Created by neon443 on 20/06/2025.
//

import SwiftUI

struct KeyManagerView: View {
	@ObservedObject var hostsManager: HostsManager
	@ObservedObject var keyManager: KeyManager
	
	var body: some View {
		ZStack {
			hostsManager.selectedTheme.background.suiColor.opacity(0.7)
				.ignoresSafeArea(.all)
			NavigationStack {
				List {
					Section {
						ForEach(hostsManager.getKeys()) { keypair in
							NavigationLink {
								KeyDetailView(hostsManager: hostsManager, keypair: keypair)
							} label: {
								Text(keypair.openSshPubkey)
							}
						}
					}
					
					Section() {
						ForEach(keyManager.keypairs) { kp in
							NavigationLink {
								KeyDetailView(hostsManager: hostsManager, keypair: kp)
							} label: {
								Image(systemName: "key")
								Text(kp.label)
								Spacer()
								Text(kp.type.description)
							}
							.swipeActions(edge: .trailing) {
								Button(role: .destructive) {
									
								} label: {
									Label("Delete", systemImage: "trash")
								}
							}
						}
					}
					
					Button("ed25519") {
						
					}
				}
				.scrollContentBackground(.hidden)
				.navigationTitle("Keys")
			}
		}
	}
}

#Preview {
	KeyManagerView(
		hostsManager: HostsManager(),
		keyManager: KeyManager()
	)
}
