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
		NavigationStack {
			List {
				Section {
					ForEach(hostsManager.getKeys()) { keypair in
						NavigationLink {
							KeyDetailView(hostsManager: hostsManager, keypair: keypair)
						} label: {
							if let publicKey = keypair.publicKey {
								Text(String(data: publicKey, encoding: .utf8) ?? "nil")
							}
						}
					}
				}
				
				Button("ed25519") {
					keyManager.generateEd25519()
				}
				Button("rsa") {
					do {
						try keyManager.generateRSA()
					} catch {
						print(error.localizedDescription)
					}
				}
			}
			.navigationTitle("Keys")
		}
	}
}

#Preview {
	KeyManagerView(
		hostsManager: HostsManager(),
		keyManager: KeyManager()
	)
}
