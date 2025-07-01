//
//  KeyDetailView.swift
//  ShhShell
//
//  Created by neon443 on 25/06/2025.
//

import SwiftUI

struct KeyDetailView: View {
	@ObservedObject var hostsManager: HostsManager
	@State var keypair: Keypair
	@State private var reveal: Bool = false
	
	var publicKey: Data {
		return keypair.publicKey ?? "".data(using: .utf8)!
	}
	var privateKey: Data {
		return keypair.privateKey ?? "".data(using: .utf8)!
	}
	
	var body: some View {
		ZStack {
			hostsManager.selectedTheme.background.suiColor.opacity(0.7)
				.ignoresSafeArea(.all)
			List {
				VStack(alignment: .leading) {
					Text("Used on")
						.bold()
					ForEach(hostsManager.getHostsKeysUsedOn([keypair])) { host in
						HStack {
							SymbolPreview(symbol: host.symbol, label: host.label)
								.frame(width: 40, height: 40)
							Text(hostsManager.makeLabel(forHost: host))
						}
					}
				}
				VStack(alignment: .leading) {
					Text("Public key")
						.bold()
					Text(keypair.openSshPubkey)
				}
				VStack(alignment: .leading) {
					Text("Private key")
						.bold()
						.frame(maxWidth: .infinity)
					ZStack(alignment: .center) {
						Text(keypair.openSshPrivkey)
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
								guard await hostsManager.authWithBiometrics() else { return }
							}
							withAnimation(.spring) { reveal.toggle() }
						}
					}
				}
				
				Button {
					Task {
						guard await hostsManager.authWithBiometrics() else { return }
						UIPasteboard.general.string = String(data: privateKey, encoding: .utf8)
					}
				} label: {
					CenteredLabel(title: "Copy private key", systemName: "document.on.document")
				}
				.listRowSeparator(.hidden)
			}
			.scrollContentBackground(.hidden)
		}
	}
}

import CryptoKit
#Preview {
	KeyDetailView(
		hostsManager: HostsManager(),
		keypair: Keypair(
			type: .ecdsa,
			name: "previewKey",
			privateKey: Curve25519.Signing.PrivateKey().rawRepresentation
		)
	)
}
