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
		
		ForEach(hostsManager.hosts) { host in
			NavigationLink() {
				ConnectionView(
					handler: SSHHandler(host: host),
					hostsManager: hostsManager,
					keyManager: keyManager
				)
			} label: {
				SymbolPreview(symbol: host.symbol, label: host.label)
					.frame(width: 40, height: 40)
				Text(hostsManager.makeLabel(forHost: host))
			}
			.id(host)
			.animation(.default, value: host)
			.swipeActions(edge: .trailing) {
				Button(role: .destructive) {
					hostsManager.removeHost(host)
				} label: {
					Label("Delete", systemImage: "trash")
				}
				Button() {
					hostsManager.duplicateHost(host)
				} label: {
					Label("Duplicate", systemImage: "square.filled.on.square")
				}
			}
		}
		.onMove(perform: {
			hostsManager.moveHost(from: $0, to: $1)
		})
		
		Section() {
			NavigationLink {
				ThemeManagerView(hostsManager: hostsManager)
			} label: {
				Label("Themes", systemImage: "swatchpalette")
			}
		}
		.transition(.opacity)
		.navigationTitle("ShhShell")
		.toolbar {
			ToolbarItem(placement: .confirmationAction) {
				NavigationLink {
					ConnectionView(
						handler: SSHHandler(host: Host.blank),
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
		handler: SSHHandler(host: Host.debug),
		hostsManager: HostsManager(),
		keyManager: KeyManager()
	)
}
