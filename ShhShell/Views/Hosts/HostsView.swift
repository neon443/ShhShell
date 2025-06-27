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
						SymbolPreview(symbol: host.symbol, label: host.label)
							.frame(width: 40, height: 40)
						Text(hostsManager.makeLabel(forHost: host))
					}
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
