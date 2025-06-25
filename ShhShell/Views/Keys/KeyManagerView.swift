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
				Section {
					NavigationLink {
						List {
							if hostsManager.savedHosts.isEmpty {
								VStack(alignment: .center) {
									Text("Looking empty 'round here...")
										.font(.title3)
										.bold()
										.padding(.bottom)
									VStack(alignment: .leading) {
										Text("Connect to some hosts to collect more hostkeys!")
											.padding(.bottom)
										Text("ShhShell remembers hostkey fingerprints for you, and can alert you if they change.")
											.font(.subheadline)
										Text("This could be due a man in the middle attack, where a bad actor tries to impersonate your server.")
											.font(.subheadline)
									}
								}
							}
							ForEach(hostsManager.savedHosts) { host in
								VStack(alignment: .leading) {
									Text(host.address)
										.bold()
									Text(host.key ?? "nil")
								}
							}
						}
					} label: {
						HStack {
							Image(systemName: "server.rack")
							Image(systemName: "key.fill")
							Text("Hostkey fingerprints")
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
		}
	}
}

#Preview {
	KeyManagerView(
		hostsManager: HostsManager(),
		keyManager: KeyManager()
	)
}
