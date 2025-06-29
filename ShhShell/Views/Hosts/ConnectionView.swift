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
	
	@State private var shellView: ShellView? = nil
	
	@State var passphrase: String = ""
	
	@State var pubkeyStr: String = ""
	@State var privkeyStr: String = ""
	
	@State var showTerminal: Bool = false
	
	@State var hostKeyChangedAlert: Bool = false
	
	var body: some View {
		NavigationStack {
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
									SymbolPreview(symbol: symbol, label: handler.host.label)
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
						SymbolPreview(symbol: handler.host.symbol, label: handler.host.label)
							.id(handler.host)
							.frame(width: 60, height: 60)
						
						TextField("label", text: $handler.host.label)
							.textFieldStyle(.roundedBorder)
					}
				}
				Section {
					Text("\(handler.state)")
						.foregroundStyle(handler.state.color)
					
					TextField("name", text: $handler.host.name)
						.textFieldStyle(.roundedBorder)
					
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
					
					TextField("", text: $pubkeyStr, prompt: Text("Public Key"))
						.onChange(of: pubkeyStr) { _ in
							let newStr = pubkeyStr.replacingOccurrences(of: "\r\n", with: "")
							handler.host.publicKey = Data(newStr.utf8)
						}
						.onSubmit {
							let newStr = pubkeyStr.replacingOccurrences(of: "\r\n", with: "")
							handler.host.publicKey = Data(newStr.utf8)
						}
					
					SecureField("", text: $privkeyStr, prompt: Text("Private Key"))
						.onSubmit {
							let newStr = privkeyStr.replacingOccurrences(of: "\r\n", with: "")
							handler.host.privateKey = Data(newStr.utf8)
						}
						.onChange(of: privkeyStr) { _ in
							let newStr = privkeyStr.replacingOccurrences(of: "\r\n", with: "")
							handler.host.privateKey = Data(newStr.utf8)
						}
					
					TextField("", text: $passphrase, prompt: Text("Passphrase (Optional)"))
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
			.alert("Hostkey changed", isPresented: $hostKeyChangedAlert) {
				Button("Accept New Hostkey", role: .destructive) {
					hostsManager.updateHost(handler.host)
					handler.go()
				}
				
				Button("Disconnect", role: .cancel) {
					handler.disconnect()
					handler.host.key = hostsManager.getHostMatching(handler.host)?.key
				}
			} message: {
				Text("Expected \(handler.host.key ?? "nil")\nbut recieved \(handler.getHostkey() ?? "nil") from the server")
			}
			.transition(.opacity)
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
		}
		.fullScreenCover(isPresented: $showTerminal) {
			if let shellView {
				shellView
			} else {
				Text("no shellview")
			}
		}
		.onChange(of: handler.host.key) { _ in
			guard let previousKnownHost = hostsManager.getHostMatching(handler.host) else { return }
			guard handler.host.key == previousKnownHost.key else {
				hostKeyChangedAlert = true
				return
			}
		}
		.onDisappear {
			hostsManager.updateHost(handler.host)
		}
		.task {
			if let publicKeyData = handler.host.publicKey {
				pubkeyStr = String(data: publicKeyData, encoding: .utf8) ?? ""
			}
			if let privateKeyData = handler.host.privateKey {
				privkeyStr = String(data: privateKeyData, encoding: .utf8) ?? ""
			}
		}
		.onAppear {
			if shellView == nil {
				shellView = ShellView(handler: handler, hostsManager: hostsManager)
			}
		}
		.onAppear {
			hostsManager.addHostIfNeeded(handler.host)
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
