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
					ForEach(hostsManager.savedHosts) { host in
						NavigationLink {
							
						} label: {
							
						}
					}
				}
				Section {
					NavigationLink {
						List {
							ForEach(hostsManager.savedHosts) { host in
								Text(host.address)
									.bold()
								Text(host.key ?? "nil")
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
