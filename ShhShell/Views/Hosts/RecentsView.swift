//
//  RecentsView.swift
//  ShhShell
//
//  Created by neon443 on 14/08/2025.
//

import SwiftUI

struct RecentsView: View {
	@ObservedObject var hostsManager: HostsManager
	@ObservedObject var keyManager: KeyManager
	
    var body: some View {
		if !hostsManager.history.isEmpty {
			Section("Recents") {
				ForEach(hostsManager.formatHistory()) { history in
					NavigationLink() {
						ConnectionView(
							handler: SSHHandler(
								host: history.host,
								keyManager: keyManager
							),
							hostsManager: hostsManager,
							keyManager: keyManager
						)
					} label: {
						Text(history.host.description)
						Text("\(history.count)")
					}
					.swipeActions {
						Button("Remove", systemImage: "trash", role: .destructive) {
							hostsManager.removeFromHistory(history.host)
						}
						.tint(.red)
					}
				}
			}
		}
    }
}

#Preview {
	RecentsView(
		hostsManager: HostsManager(),
		keyManager: KeyManager()
	)
}
