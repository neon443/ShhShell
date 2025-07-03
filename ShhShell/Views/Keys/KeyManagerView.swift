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
	
	@State var showImporter: Bool = false
	
	var body: some View {
		ZStack {
			hostsManager.selectedTheme.background.suiColor.opacity(0.7)
				.ignoresSafeArea(.all)
			NavigationStack {
				List {
					Section() {
						ForEach(keyManager.keypairs) { kp in
							NavigationLink {
								KeyDetailView(
									hostsManager: hostsManager,
									keyManager: keyManager,
									keypair: kp
								)
							} label: {
								HStack {
									Image(systemName: "key")
									if kp.label.isEmpty {
										Text(kp.id.uuidString)
									} else {
										Text(kp.label)
									}
									Spacer()
									Text(kp.type.description)
										.foregroundStyle(.gray)
								}
							}
							.swipeActions(edge: .trailing) {
								Button(role: .destructive) {
									keyManager.deleteKey(kp)
								} label: {
									Label("Delete", systemImage: "trash")
								}
							}
						}
						.id(keyManager.keypairs)
					}
					
					Button("Generate a new Ed25519 Key") {
						let comment = UIDevice().model + " at " + Date().formatted(date: .numeric, time: .omitted)
						keyManager.generateKey(type: .ed25519, comment: comment)
					}
					
					Button("Import Key") { showImporter.toggle() }
						.sheet(isPresented: $showImporter) {
							KeyImporterView(keyManager: keyManager)
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
