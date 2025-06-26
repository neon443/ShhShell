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
	
    var body: some View {
		List {
			VStack(alignment: .leading) {
				Text("Public key")
					.bold()
				Text(String(data: keypair.publicKey!, encoding: .utf8) ?? "nil")
			}
			VStack(alignment: .leading) {
				Text("Private key")
					.bold()
					.frame(maxWidth: .infinity)
				ZStack(alignment: .center) {
					Text(String(data: keypair.privateKey!, encoding: .utf8) ?? "nil")
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
					if let privateKey = keypair.privateKey {
						UIPasteboard.general.string = String(data: privateKey, encoding: .utf8)
					}
				}
			} label: {
				CenteredLabel(title: "Copy private key", systemName: "document.on.document")
			}
			.listRowSeparator(.hidden)
		}
    }
}

#Preview {
	KeyDetailView(
		hostsManager: HostsManager(),
		keypair: Keypair(
			publicKey: "ssh-ed25519 dskjhfajkdhfjkdashfgjkhadsjkgfbhalkjhfjkhdask user@mac".data(using: .utf8),
			privateKey: """
						-----BEGIN OPENSSH PRIVATE KEY-----
						Lorem ipsum dolor sit amet, consectetur adipiscing elit
						sed do eiusmod tempor incididunt ut labore et dolore magna aliqu
						Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris 
						nisi ut aliquip ex ea commodo consequat
						-----END OPENSSH PRIVATE KEY-----
						"""
				.data(using: .utf8)
		)
	)
}
