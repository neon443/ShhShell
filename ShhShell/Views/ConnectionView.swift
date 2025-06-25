//
//  ConnectionView.swift
//  ShhShell
//
//  Created by neon443 on 20/06/2025.
//

import SwiftUI

struct ConnectionView: View {
	@ObservedObject var handler: SSHHandler
	@ObservedObject var hostsManager: HostsManager
	@ObservedObject var keyManager: KeyManager
	
	@State var passphrase: String = ""
	
	@State var pubkeyStr: String = ""
	@State var privkeyStr: String = ""
	
	@State var showTerminal: Bool = false
	
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
								let newStr = pubkeyStr.replacingOccurrences(of: "\r\n", with: "")
								handler.host.publicKey = Data(newStr.utf8)
							}
					}
					
					HStack {
						SecureField("", text: $privkeyStr, prompt: Text("Private Key"))
							.onSubmit {
								let newStr = privkeyStr.replacingOccurrences(of: "\r\n", with: "")
								handler.host.privateKey = Data(newStr.utf8)
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
				
				Button() {
					showTerminal.toggle()
				} label: {
					Label("Show Terminal", systemImage: "apple.terminal")
				}
				.disabled(!handler.connected || !handler.authorized)
				
				Button() {
					if handler.authorized && handler.connected {
					} else {
						handler.go()
					}
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
					Task {
						await handler.disconnect()
						handler.host.key = hostsManager.getHostMatching(handler.host)?.key
					}
				}
			} message: {
				Text("Expected \(hostsManager.getHostMatching(handler.host)?.key?.base64EncodedString() ?? "null")\nbut recieved \(handler.host.key?.base64EncodedString() ?? "null" ) from the server")
			}
			.transition(.opacity)
			.toolbar {
				ToolbarItem() {
					Button() {
						handler.go()
						showTerminal = handler.connected && handler.authorized
					} label: {
						Label(
							handler.connected ? "Disconnect" : "Connect",
							systemImage: handler.connected ? "xmark.app.fill" : "power"
						)
					}
				}
			}
		}
		.fullScreenCover(isPresented: $showTerminal) {
			ShellView(handler: handler)
		}
		.onDisappear {
			guard hostsManager.getHostMatching(handler.host) == handler.host else {
				hostsManager.updateHost(handler.host)
				return
			}
		}
		.task {
			if let publicKeyData = handler.host.publicKey {
				pubkeyStr = String(data: publicKeyData, encoding: .utf8) ?? ""
			}
			if let privateKeyData = handler.host.privateKey {
				privkeyStr = String(data: privateKeyData, encoding: .utf8) ?? ""
			}
		}
	}
}


#Preview {
	ConnectionView(
		handler: SSHHandler(host: Host.debug),
		hostsManager: HostsManager(),
		keyManager: KeyManager()
	)
}
