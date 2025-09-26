//
//  ContentView.swift
//  ShhShell
//
//  Created by neon443 on 02/06/2025.
//

import SwiftUI

struct ContentView: View {
	@ObservedObject var handler: SSHHandler
	@ObservedObject var hostsManager: HostsManager
	@ObservedObject var keyManager: KeyManager
	
	var body: some View {
		NavigationSplitView {
			ZStack {
				hostsManager.selectedTheme.background.suiColor.opacity(0.7)
					.ignoresSafeArea(.all)
				List {
					SessionsListView(
						handler: handler,
						hostsManager: hostsManager,
						keyManager: keyManager
					)
					
					RecentsView(
						hostsManager: hostsManager,
						keyManager: keyManager
					)
					
					HostsView(
						handler: handler,
						hostsManager: hostsManager,
						keyManager: keyManager
					)
					
					Section() {
						NavigationLink {
							ThemeManagerView(hostsManager: hostsManager)
						} label: {
							Label("Themes", systemImage: "swatchpalette")
						}
						NavigationLink {
							FontManagerView(hostsManager: hostsManager)
						} label: {
							Label("Fonts", systemImage: "textformat")
						}
					}
					
					Section {
						NavigationLink {
							SnippetManagerView(hostsManager: hostsManager)
						} label: {
							Label("Snippets", systemImage: "paperclip")
						}
						
						NavigationLink {
							KeyManagerView(hostsManager: hostsManager, keyManager: keyManager)
						} label: {
							Label("Keys", systemImage: "key.fill")
						}
						
						NavigationLink {
							HostkeysView(hostsManager: hostsManager)
						} label: {
							Label("Hostkey Fingerprints", systemImage: "lock.display")
						}
					}
					
					Section {
						NavigationLink {
							SettingsView(hostsManager: hostsManager, keyManager: keyManager)
						} label: {
							Label("Settings", systemImage: "gear")
						}
						NavigationLink {
							AboutView(hostsManager: hostsManager)
						} label: {
							Label("About", systemImage: "info.square")
						}
					}
				}
				.scrollContentBackground(.hidden)
			}
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
		} detail: {
			Text("Detail?")
		}
	}
}

#Preview {
	let keymanager = KeyManager()
	ContentView(
		handler: SSHHandler(host: Host.debug, keyManager: keymanager),
		hostsManager: HostsManager(),
		keyManager: keymanager
	)
}
