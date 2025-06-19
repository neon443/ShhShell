//
//  ContentView.swift
//  ShhShell
//
//  Created by neon443 on 02/06/2025.
//

import SwiftUI

struct ContentView: View {
	@ObservedObject var handler: SSHHandler
	
	@State var pubkey: String = ""
	@State var privkey: String = ""
	@State var passphrase: String = ""
	
    var body: some View {
		NavigationStack {
			List {
				TextField("", text: $pubkey)
				TextField("", text: $privkey)
				TextField("", text: $passphrase)
				HStack {
					Text(handler.connected ? "connected" : "not connected")
						.modifier(foregroundColorStyle(handler.connected ? .green : .red))
					
					Text(handler.authorized ? "authorized" : "unauthorized")
						.modifier(foregroundColorStyle(handler.authorized ? .green : .red))
				}
				
//				if let testSucceded = testSucceded {
//					Image(systemName: testSucceded ? "checkmark.circle" : "xmark.circle")
//						.modifier(foregroundColorStyle(testSucceded ? .green : .red))
//				}
				
				if handler.host.key != nil {
					Text("Hostkey: \(handler.host.key!.base64EncodedString())")
				}
				
				TextField("address", text: $handler.host.address)
					.textFieldStyle(.roundedBorder)
				
				TextField(
					"port",
					text: Binding(
						get: { String(handler.host.port) },
						set: { handler.host.port = Int($0) ?? 22} )
				)
				.keyboardType(.numberPad)
				.textFieldStyle(.roundedBorder)
				
				TextField("username", text: $handler.host.username)
					.textFieldStyle(.roundedBorder)
				
				SecureField("password", text: $handler.host.password)
					.textFieldStyle(.roundedBorder)
				
				Button() {
					handler.connect()
					if !pubkey.isEmpty && !privkey.isEmpty {
						handler.authWithPubkey(pub: pubkey, priv: privkey, pass: passphrase)
					} else {
						let _ = handler.authWithPw()
					}
					handler.openShell()
				} label: {
					Label("Connect", systemImage: "powerplug.portrait")
				}
				.disabled(handler.connected)
				
				NavigationLink() {
					TerminalView(handler: handler)
				} label: {
					Label("Open Terminal", systemImage: "apple.terminal")
				}
				.disabled(!(handler.connected && handler.authorized))
				
				Button() {
					withAnimation { handler.testExec() }
				} label: {
					if handler.testSuceeded {
						Image(systemName: handler.testSuceeded ? "checkmark.circle" : "xmark.circle")
							.modifier(foregroundColorStyle(handler.testSuceeded ? .green : .red))
					} else {
						Label("Test Connection", systemImage: "checkmark")
					}
				}
				.disabled(!(handler.connected && handler.authorized))
			}
			.transition(.opacity)
		}
    }
}

#Preview {
    ContentView(
		handler: SSHHandler(host: debugHost())
	)
}
