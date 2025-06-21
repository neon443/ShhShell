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
	@StateObject var hostsManager: HostsManager
	
	@State var passphrase: String = ""
	
	@State var pubkeyStr: String = ""
	@State var privkeyStr: String = ""
	
	@State var pubkey: Data?
	@State var privkey: Data?
	
	@State var privPickerPresented: Bool = false
	@State var pubPickerPresented: Bool = false
	
	@State var hostKeyChangedAlert: Bool = false
	
	var body: some View {
		NavigationStack {
			List {
				Section {
					HStack {
						Text(handler.connected ? "connected" : "not connected")
							.modifier(foregroundColorStyle(handler.connected ? .green : .red))
						
						Text(handler.authorized ? "authorized" : "unauthorized")
							.modifier(foregroundColorStyle(handler.authorized ? .green : .red))
					}
					TextField("address", text: $handler.host.address)
						.textFieldStyle(.roundedBorder)
					
					TextField(
						"port",
						text: Binding(
							get: { String(handler.host.port) },
							set: {
								if let input = Int($0) {
									handler.host.port = input
								}
							}
						)
					)
					.keyboardType(.numberPad)
					.textFieldStyle(.roundedBorder)
				}
				
				Section {
					TextField("Username", text: $handler.host.username)
						.textFieldStyle(.roundedBorder)
					
					SecureField("Password", text: $handler.host.password)
						.textFieldStyle(.roundedBorder)
					
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
					TextField("", text: $passphrase, prompt: Text("Passphrase (Optional)"))
				}
				
				if handler.host.key != nil {
					Text("Hostkey: \(handler.host.key!.base64EncodedString())")
						.onChange(of: handler.host.key) { _ in
							guard let previousKnownHost = hostsManager.getHostMatching(handler.host) else { return }
							guard handler.host.key == previousKnownHost.key else {
								hostKeyChangedAlert = true
								return
							}
						}
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
					if let testResult = handler.testSuceeded {
						Image(systemName: testResult ? "checkmark.circle" : "xmark.circle")
							.modifier(foregroundColorStyle(testResult ? .green : .red))
					} else {
						Label("Test Connection", systemImage: "checkmark")
					}
				}
			}
			.alert("Hostkey changed", isPresented: $hostKeyChangedAlert) {
				Button("Accept New Hostkey", role: .destructive) {
					hostsManager.updateHost(handler.host)
				}
				
				Button("Disconnect", role: .cancel) {
					handler.disconnect()
					handler.host.key = hostsManager.getHostMatching(handler.host)?.key
				}
			} message: {
				Text("""
						Expected \(hostsManager.getHostMatching(handler.host)!.key!.base64EncodedString())
						but recieved \(handler.host.key!.base64EncodedString()) from the server
					""")
			}
			.transition(.opacity)
			.toolbar {
				ToolbarItem() {
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
							pubkey == nil && privkey == nil &&
							handler.host.username.isEmpty && handler.host.password.isEmpty
						)
					}
				}
			}
		}
		.onDisappear {
			guard hostsManager.getHostMatching(handler.host) == handler.host else {
				hostsManager.updateHost(handler.host)
				return
			}
		}
	}
}


#Preview {
	ConnectionView(
		handler: SSHHandler(host: Host.debug),
		keyManager: KeyManager(),
		hostsManager: HostsManager()
	)
}
