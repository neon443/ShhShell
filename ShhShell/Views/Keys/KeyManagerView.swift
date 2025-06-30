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
								if let publicKey = keypair.publicKey {
									Text(String(data: publicKey, encoding: .utf8) ?? "nil")
								}
							}
						}
					}
					
					Button("ed25519") {
						keyManager.generateEd25519()
					}
					
					Button("genereate rsa") {
						let key = keyManager.generateKey(type: .rsa(4096), SEPKeyTag: "", comment: "jaklsd", passphrase: "")
						print(String(data: key!.privateKey!, encoding: .utf8) ?? "asd")
						print(String(data: key!.publicKey!, encoding: .utf8) ?? "asd")
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
