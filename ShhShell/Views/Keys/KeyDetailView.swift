//
//  KeyDetailView.swift
//  ShhShell
//
//  Created by neon443 on 25/06/2025.
//

import SwiftUI

struct KeyDetailView: View {
	@ObservedObject var hostsManager: HostsManager
	@ObservedObject var keyManager: KeyManager
	@State var keypair: Keypair
	
	@State var keyname: String = ""
	@State private var reveal: Bool = false
	
	@Environment(\.dismiss) var dismiss
	
	var body: some View {
		ZStack {
			hostsManager.selectedTheme.background.suiColor.opacity(0.7)
				.ignoresSafeArea(.all)
			List {
				VStack(alignment: .leading) {
					Text("Used on")
						.bold()
					ForEach(hostsManager.getHostsUsingKeys([keypair])) { host in
						HStack {
							HostSymbolPreview(symbol: host.symbol, label: host.label)
								.frame(width: 40, height: 40)
							Text(host.description)
						}
					}
					Menu("Add") {
						let hostsNotUsingKey = hostsManager.hosts.filter(
							{
								hostsManager.getHostsUsingKeys([keypair]).contains($0)
							})
						ForEach(hostsNotUsingKey) { host in
							Button() {
								hostsManager.set(keypair: keypair, onHost: host)
							} label: {
								Image(systemName: "plus")
									.resizable().scaledToFit()
									.foregroundStyle(.blue)
									.frame(width: 30, height: 30)
								Text("Add")
									.foregroundStyle(.blue)
							}
						}
					}
				}
				
				Section() {
					TextBox(label: "Name", text: $keyname, prompt: "A name for your key")
						.onAppear {
							keyname = keypair.name
						}
						.onChange(of: keyname) { _ in
							keyManager.renameKey(keypair: keypair, newName: keyname)
						}
					
					Button {
						UIPasteboard.general.string = keypair.openSshPubkey
					} label: {
						CenteredLabel(title: "Copy public key", systemName: "document.on.document")
					}
					.listRowSeparator(.hidden)
					
					Button {
						Task {
							guard await authWithBiometrics() else { return }
							UIPasteboard.general.string = String(data: KeyManager.makeSSHPrivkey(keypair), encoding: .utf8) ?? ""
						}
					} label: {
						CenteredLabel(title: "Copy private key", systemName: "document.on.document")
					}
					.listRowSeparator(.hidden)
					
					CenteredLabel(title: "Delete", systemName: "trash")
						.foregroundStyle(.red)
						.onTapGesture {
							keyManager.deleteKey(keypair)
							dismiss()
						}
				}
				
				Section("Key") {
					VStack(alignment: .leading) {
						Text("Public key")
							.bold()
						Text(keypair.openSshPubkey.dropLast(2))
					}
					VStack(alignment: .leading) {
						Text("Private key")
							.bold()
							.frame(maxWidth: .infinity)
						ZStack(alignment: .center) {
							Text(keypair.openSshPrivkey.dropLast(2))
								.blur(radius: reveal ? 0 : 5)
							VStack {
								Image(systemName: "eye.slash.fill")
									.resizable().scaledToFit()
									.frame(width: 50)
								Text("Tap to reveal")
							}
							.opacity(reveal ? 0 : 1)
						}
						.frame(maxWidth: .infinity)
						.onTapGesture {
							Task {
								if !reveal {
									guard await authWithBiometrics() else { return }
								}
								withAnimation(.spring) { reveal.toggle() }
							}
						}
					}
				}
			}
			.scrollContentBackground(.hidden)
		}
	}
}

import CryptoKit
#Preview {
	KeyDetailView(
		hostsManager: HostsManager(),
		keyManager: KeyManager(),
		keypair: Keypair(
			type: .ed25519,
			name: "previewKey",
			privateKey: Curve25519.Signing.PrivateKey().rawRepresentation
		)
	)
}
