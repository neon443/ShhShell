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
		NavigationStack {
			List {
				if hostsManager.savedHosts.isEmpty {
					Text("Add your first Host!")
					Button() {
						withAnimation { hostsManager.savedHosts.append(Host.blank) }
					} label: {
						Text("Create")
					}
					.buttonStyle(.borderedProminent)
				}
				
				//proves that u can connect to multiple at the same time
				NavigationLink() {
					ForEach(hostsManager.savedHosts) { host in
						let miniHandler = SSHHandler(host: host)
						TerminalController(handler: miniHandler)
							.onAppear { miniHandler.go() }
					}
				} label: {
					Label("multiview", systemImage: "square.split.2x2")
				}
				
				ForEach(hostsManager.savedHosts) { host in
					NavigationLink() {
						ConnectionView(
							handler: SSHHandler(host: host),
							hostsManager: hostsManager,
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
							if let index = hostsManager.savedHosts.firstIndex(where: { $0.id == host.id }) {
								let _ = withAnimation { hostsManager.savedHosts.remove(at: index) }
								hostsManager.saveSavedHosts()
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
							hostsManager: hostsManager,
							keyManager: keyManager
						)
						.onAppear {
							withAnimation { hostsManager.savedHosts.append(host) }
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
		hostsManager: HostsManager(),
		keyManager: KeyManager()
	)
}
