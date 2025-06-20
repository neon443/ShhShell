//
//  ConnectionView.swift
//  ShhShell
//
//  Created by neon443 on 20/06/2025.
//

import SwiftUI

struct ConnectionView: View {
	@StateObject var handler: SSHHandler
	@StateObject var keyManager: KeyManager
	
	@State var passphrase: String = ""
	
	@State var pubkeyStr: String = ""
	@State var privkeyStr: String = ""
	
	@State var pubkey: Data?
	@State var privkey: Data?
	
	@State var privPickerPresented: Bool = false
	@State var pubPickerPresented: Bool = false
	
	var body: some View {
		NavigationStack {
			List {
				HStack {
					TextField("", text: $pubkeyStr, prompt: Text("Public Key"))
						.onSubmit {
							pubkey = Data(pubkeyStr.utf8)
						}
					Button() {
						pubPickerPresented.toggle()
					} label: {
						Image(systemName: "folder")
					}
					.buttonStyle(.plain)
					.fileImporter(isPresented: $pubPickerPresented, allowedContentTypes: [.item, .content, .data]) { (Result) in
						do {
							let fileURL = try Result.get()
							pubkey = try! Data(contentsOf: fileURL)
							print(fileURL)
						} catch {
							print(error.localizedDescription)
						}
					}
				}
				
				HStack {
					TextField("", text: $privkeyStr, prompt: Text("Private Key"))
						.onSubmit {
							privkey = Data(privkeyStr.utf8)
						}
					Button() {
						privPickerPresented.toggle()
					} label: {
						Image(systemName: "folder")
					}
					.buttonStyle(.plain)
					.fileImporter(isPresented: $privPickerPresented, allowedContentTypes: [.item, .content, .data]) { (Result) in
						do {
							let fileURL = try Result.get()
							privkey = try! Data(contentsOf: fileURL)
							print(fileURL)
						} catch {
							print(error.localizedDescription)
						}
					}
				}
				
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
				
				if handler.connected {
					Button() {
						handler.disconnect()
					} label: {
						Label("Disconnect", systemImage: "xmark.app.fill")
					}
				} else {
					Button() {
						handler.connect()
						if pubkey != nil && privkey != nil {
							handler.authWithPubkey(pub: pubkey!, priv: privkey!, pass: passphrase)
						} else {
							let _ = handler.authWithPw()
						}
						handler.openShell()
					} label: {
						Label("Connect", systemImage: "powerplug.portrait")
					}
					.disabled(
						pubkey == nil && privkey == nil ||
						handler.host.username.isEmpty && handler.host.password.isEmpty
					)
				}
				
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
	ConnectionView(
		handler: SSHHandler(host: debugHost()),
		keyManager: KeyManager()
	)
}
