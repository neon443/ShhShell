//
//  ContentView.swift
//  ShhShell
//
//  Created by neon443 on 02/06/2025.
//

import SwiftUI

struct ContentView: View {
	@ObservedObject var handler: SSHHandler
	@State var connected: Bool = false
	@State var testSucceded: Bool?
	
	@State var terminal: String = ""
	
    var body: some View {
        VStack {
			Text(connected ? "connected" : "not connected")
				.modifier(foregroundColorStyle(connected ? .green : .red))
			
			Text(handler.authorized ? "authorized" : "unauthorized")
				.modifier(foregroundColorStyle(handler.authorized ? .green : .red))
			
			if let testSucceded = testSucceded {
				Image(systemName: testSucceded ? "checkmark.circle" : "xmark.circle")
					.modifier(foregroundColorStyle(testSucceded ? .green : .red))
			}
			
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
			
			TextField("password", text: $handler.host.password)
				.textFieldStyle(.roundedBorder)

			Button("connect") {
				if handler.connect() {
					withAnimation { connected = true }
				}
				handler.authWithPw()
			}
			.disabled(connected)
			
			Button("disconnect") {
				handler.disconnect()
				withAnimation { testSucceded = false }
				withAnimation { connected = false }
				withAnimation { testSucceded = nil }
			}
			.disabled(!connected)
			
			Button("run a test command") {
				if handler.testExec() {
					withAnimation { testSucceded = true }
				} else {
					withAnimation { testSucceded = false }
				}
			}
			.disabled(!(connected && handler.authorized))
			
			Button("request a shell") {
				handler.openShell()
				terminal.append(handler.readFromChannel() ?? "")
			}
			
			Button("read from server") {
				terminal.append(handler.readFromChannel() ?? "")
			}
			
			Text(terminal)
        }
    }
}

#Preview {
    ContentView(
		handler: SSHHandler(host: debugHost())
	)
}
