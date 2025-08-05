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
	
	@State var pubkeyStr: String = ""
	@State var privkeyStr: String = ""
	
	@State var showTerminal: Bool = false
	
	var body: some View {
		ZStack {
			hostsManager.selectedTheme.background.suiColor.opacity(0.7)
				.ignoresSafeArea(.all)
			List {
				Section {
					ScrollView(.horizontal) {
						HStack {
							ForEach(HostSymbol.allCases, id: \.self) { symbol in
								ZStack {
									if handler.host.symbol == symbol {
										RoundedRectangle(cornerRadius: 10)
											.fill(.gray.opacity(0.5))
									}
									HostSymbolPreview(symbol: symbol, label: handler.host.label)
										.padding(5)
								}
								.frame(width: 60, height: 60)
								.onTapGesture {
									withAnimation { handler.host.symbol = symbol }
								}
							}
						}
					}
					
					HStack {
						HostSymbolPreview(symbol: handler.host.symbol, label: handler.host.label)
							.id(handler.host)
							.frame(width: 60, height: 60)
						
						TextBox(label: "Icon Text", text: $handler.host.label, prompt: "a few letters in the icon")
					}
				}
				Section {
					Text("\(handler.state)")
						.foregroundStyle(handler.state.color)
					
					TextBox(label: "Name", text: $handler.host.name, prompt: "defaults to host address")
					
					TextBox(label: "Address", text: $handler.host.address, prompt: "required")
					
					TextBox(label: "Port", text: Binding(
						get: { String(handler.host.port) },
						set: {
							if let input = Int($0) {
								handler.host.port = input
							}
						}),
							prompt: "most likely 22",
							keyboardType: .numberPad
					)
				}
				
				Section {
					TextBox(label: "Username", text: $handler.host.username, prompt: "required")
					
					TextBox(label: "Password", text: $handler.host.password, prompt: "not required if using publickeys", secure: true)
					
					Picker("Private key", selection: $handler.host.privateKeyID) {
						ForEach(keyManager.keypairs) { keypair in
							Text(keypair.label)
								.tag(keypair.id as UUID?)
						}
						Divider()
						Text("None")
							.tag(nil as UUID?)
					}
				}
				
				Button() {
					showTerminal.toggle()
				} label: {
					Label("Show Terminal", systemImage: "apple.terminal")
				}
				.disabled(!checkShell(handler.state))
				
				Button() {
					handler.testExec()
				} label: {
					if let testResult = handler.testSuceeded {
						Image(systemName: testResult ? "checkmark.circle" : "xmark.circle")
							.modifier(foregroundColorStyle(testResult ? .green : .red))
					} else {
						Label("Test Connection", systemImage: "checkmark")
					}
				}
			}
			.scrollContentBackground(.hidden)
			.transition(.opacity)
			.onDisappear {
				hostsManager.updateHost(handler.host)
			}
			.alert("Hostkey changed", isPresented: $handler.hostkeyChanged) {
				Button(role: .destructive) {
					handler.host.key = handler.getHostkey()
					handler.disconnect()
//					handler.go()
//					showTerminal = checkShell(handler.state)
				} label: {
					Text("Accept Hostkey")
				}
				
				Button(role: .cancel) {
					handler.disconnect()
				} label: {
					Text("Disconnect")
						.tint(.blue)
						.foregroundStyle(.blue)
				}
				.tint(.blue)
				.foregroundStyle(.blue)
			} message: {
				if let expectedKey = handler.host.key {
					Text("Expected \(expectedKey)\nbut recieved\n \(handler.getHostkey() ?? "nil") from server")
				} else {
					Text("""
The authenticity of \(handler.host.description) can't be established.
Hostkey fingerprint is \(handler.getHostkey() ?? "nil")
""")
				}
			}
			.toolbar {
				ToolbarItem() {
					Button() {
						handler.go()
						showTerminal = checkShell(handler.state)
					} label: {
						Label(
							handler.connected ? "Disconnect" : "Connect",
							systemImage: handler.connected ? "xmark.app.fill" : "power"
						)
					}
					.disabled(handler.hostInvalid())
				}
			}
			.fullScreenCover(isPresented: $showTerminal) {
				ShellTabView(handler: handler, hostsManager: hostsManager)
			}
		}
	}
}


#Preview {
	let keymanager = KeyManager()
	ConnectionView(
		handler: SSHHandler(host: Host.debug, keyManager: keymanager),
		hostsManager: HostsManager(),
		keyManager: keymanager
	)
}
