//
//  HostsView.swift
//  ShhShell
//
//  Created by neon443 on 20/06/2025.
//

import SwiftUI

struct HostsView: View {
	@ObservedObject var handler: SSHHandler
	@ObservedObject var hostsManager: HostsManager
	@ObservedObject var keyManager: KeyManager
	
	var body: some View {
		if hostsManager.hosts.isEmpty {
			Text("Add your first Host!")
		}
		
		Section("Hosts") {
			ForEach(hostsManager.hosts) { host in
				NavigationLink() {
					ConnectionView(
						handler: SSHHandler(host: host, keyManager: keyManager),
						hostsManager: hostsManager,
						keyManager: keyManager
					)
				} label: {
					HostSymbolPreview(symbol: host.symbol, label: host.label)
						.frame(width: 40, height: 40)
					Text(host.description)
				}
				.id(host)
				.animation(.default, value: host)
				.swipeActions(edge: .trailing) {
					Button(role: .destructive) {
						hostsManager.removeHost(host)
					} label: {
						Label("Delete", systemImage: "trash")
					}
					.tint(.red)
					Button() {
						hostsManager.duplicateHost(host)
					} label: {
						Label("Duplicate", systemImage: "square.filled.on.square")
					}
					.tint(.blue)
				}
			}
			.onMove(perform: {
				hostsManager.moveHost(from: $0, to: $1)
			})
		}
		.transition(.opacity)
		.navigationTitle("ShhShell")
		.toolbar {
			ToolbarItem(placement: .confirmationAction) {
				NavigationLink {
					ConnectionView(
						handler: SSHHandler(host: Host.blank, keyManager: keyManager),
						hostsManager: hostsManager,
						keyManager: keyManager
					)
				} label: {
					Label("Add", systemImage: "plus")
				}
			}
		}
	}
}

#Preview {
	HostsView(
		handler: SSHHandler(host: Host.debug, keyManager: nil),
		hostsManager: HostsManager(),
		keyManager: KeyManager()
	)
}
