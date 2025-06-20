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
				Text("hi")
				ForEach(hostsManager.savedHosts) { host in
					NavigationLink() {
						ConnectionView(
							handler: SSHHandler(host: host),
							keyManager: keyManager,
							hostsManager: hostsManager
						)
					} label: {
						Text(host.address)
					}
				}
			}
			.toolbar {
				ToolbarItem(placement: .confirmationAction) {
					Button {
						hostsManager.savedHosts.append(Host.blank)
					} label: {
						Label("Add", systemImage: "plus")
					}
				}
			}
		}
    }
}

#Preview {
	HostsView(keyManager: KeyManager(), hostsManager: HostsManager())
}
