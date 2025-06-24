//
//  HostsView.swift
//  ShhShell
//
//  Created by neon443 on 20/06/2025.
//

import SwiftUI

struct HostsView: View {
	@ObservedObject var handler: SSHHandler
	@ObservedObject var keyManager: KeyManager
	
    var body: some View {
		NavigationStack {
			List {
				if handler.hostsManager.savedHosts.isEmpty {
					Text("Add your first Host!")
					Button() {
						withAnimation { handler.hostsManager.savedHosts.append(Host.blank) }
					} label: {
						Text("Create")
//							.font()
					}
					.buttonStyle(.borderedProminent)
				}
				ForEach(handler.hostsManager.savedHosts) { host in
					NavigationLink() {
						ConnectionView(
							handler: SSHHandler(host: host),
							keyManager: keyManager
						)
					} label: {
						if host.address.isEmpty {
							Text(host.id.uuidString)
						} else {
							Text(host.address)
						}
					}
					.animation(.default, value: host)
					.swipeActions(edge: .trailing) {
						Button(role: .destructive) {
							if let index = handler.hostsManager.savedHosts.firstIndex(where: { $0.id == host.id }) {
								let _ = withAnimation { handler.hostsManager.savedHosts.remove(at: index) }
								handler.hostsManager.saveSavedHosts()
							}
						} label: {
							Label("Delete", systemImage: "trash")
						}
					}
				}
			}
			.transition(.opacity)
			.toolbar {
				ToolbarItem(placement: .confirmationAction) {
					let host = Host.blank
					NavigationLink {
						ConnectionView(
							handler: SSHHandler(host: host),
							keyManager: keyManager
						)
						.task(priority: .userInitiated) {
							withAnimation { handler.hostsManager.savedHosts.append(host) }
						}
					} label: {
						Label("Add", systemImage: "plus")
					}
				}
			}
		}
    }
}

#Preview {
	HostsView(
		handler: SSHHandler(host: Host.debug),
		keyManager: KeyManager()
	)
}
