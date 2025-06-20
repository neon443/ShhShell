//
//  HostsView.swift
//  ShhShell
//
//  Created by neon443 on 20/06/2025.
//

import SwiftUI

struct HostsView: View {
	@ObservedObject var keyManager: KeyManager
	@ObservedObject var hostsManager: HostsManager
	
    var body: some View {
		NavigationStack {
			List {
				if hostsManager.savedHosts.isEmpty {
					Text("Add your first Host!")
					Button() {
						withAnimation { hostsManager.savedHosts.append(Host.blank) }
					} label: {
						Text("Create")
//							.font()
					}
					.buttonStyle(.borderedProminent)
				}
				ForEach(hostsManager.savedHosts) { host in
					HStack {
						if host.address.isEmpty {
							Text(host.id.uuidString)
						} else {
							Text(host.address)
						}
						NavigationLink() {
							ConnectionView(
								handler: SSHHandler(host: host),
								keyManager: keyManager,
								hostsManager: hostsManager
							)
						} label: {
							Image(systemName: "info.circle")
						}
						.onChange(of: host) { _ in
							hostsManager.saveSavedHosts()
						}
					}
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
			.transition(.scale)
			.toolbar {
				ToolbarItem(placement: .confirmationAction) {
					if !hostsManager.savedHosts.isEmpty {
						NavigationLink {
							ConnectionView(
								handler: SSHHandler(host: hostsManager.savedHosts.last!),
								keyManager: keyManager,
								hostsManager: hostsManager
							)
							.onAppear() {
								withAnimation { hostsManager.savedHosts.append(Host.blank) }
							}
						} label: {
							Label("Add", systemImage: "plus")
						}
					}
				}
			}
		}
    }
}

#Preview {
	HostsView(keyManager: KeyManager(), hostsManager: HostsManager())
}
