//
//  HostPreview.swift
//  ShhShell
//
//  Created by neon443 on 17/08/2025.
//

import SwiftUI

struct HostPreview: View {
	@ObservedObject var hostsManager: HostsManager
	@ObservedObject var keyManager: KeyManager
	@State var host: Host
	
	var body: some View {
		List {
			HStack {
				Image(systemName: "info.circle")
				Text("Info for \"\(host.description)\"")
					.monospaced()
				Spacer()
				HostSymbolPreview(symbol: host.symbol, label: host.label)
					.frame(maxHeight: 30)
			}
			
			Section {
				TextBox(label: "Name", text: $host.name, prompt: "")
				
				TextBox(label: "Address", text: $host.address, prompt: "")
				
				TextBox(label: "Port", text: Binding(
					get: { String(host.port) },
					set: {
						if let input = Int($0) {
							host.port = input
						}
					}),
						prompt: "",
						keyboardType: .numberPad
				)
			}
			
			Section {
				TextBox(label: "Username", text: $host.username, prompt: "")
				
				TextBox(label: "Password", text: $host.password, prompt: "", secure: true)
				
				let keypair = keyManager.keypairs.first(where: { $0.id == host.privateKeyID })
				TextBox(label: "Private key", text: .constant(keypair?.name ?? "None"), prompt: "")
			}
			
			Section() {
				let startupSnip = hostsManager.snippets.first(where: { $0.id == host.startupSnippetID })
				TextBox(label: "Startup Snippet", text: .constant(startupSnip?.name ?? "None"), prompt: "")
			}
		}
	}
}

#Preview {
	HostPreview(
		hostsManager: HostsManager(),
		keyManager: KeyManager(),
		host: Host.debug
	)
}
