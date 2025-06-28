//
//  HostkeysView.swift
//  ShhShell
//
//  Created by neon443 on 28/06/2025.
//

import SwiftUI

struct HostkeysView: View {
	@ObservedObject var hostsManager: HostsManager
	
    var body: some View {
		NavigationStack {
			List {
				if hostsManager.hosts.isEmpty {
					VStack(alignment: .leading) {
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
				
				ForEach(hostsManager.hosts) { host in
					VStack(alignment: .leading) {
						if !host.name.isEmpty {
							Text("name")
								.foregroundStyle(.gray)
								.font(.caption)
							Text(host.name)
								.bold()
						}
						Text("address")
							.foregroundStyle(.gray)
							.font(.caption)
						Text(host.address)
							.bold()
						Text(host.key ?? "nil")
					}
				}
			}
			.navigationTitle("Hostkeys")
		}
    }
}

#Preview {
    HostkeysView(hostsManager: HostsManager())
}
