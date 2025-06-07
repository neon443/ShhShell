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
				.foregroundStyle(connected ? .green : .red)
			
			Text(handler.authorized ? "authorized" : "unauthorized")
				.foregroundStyle(handler.authorized ? .green : .red)
			
			if let testSucceded = testSucceded {
				Image(systemName: testSucceded ? "checkmark.circle" : "xmark.circle")
					.foregroundStyle(testSucceded ? .green : .red)
			}
			
			if handler.hostkey != nil {
				Text("Hostkey: \(handler.hostkey!.base64EncodedString())")
			}
			
			TextField("address", text: $handler.address)
				.textFieldStyle(.roundedBorder)
			
			TextField(
				"port",
				text: Binding(
					get: { String(handler.port) },
					set: { handler.port = Int($0) ?? 22} )
			)
				.keyboardType(.numberPad)
				.textFieldStyle(.roundedBorder)
			
			TextField("username", text: $handler.username)
				.textFieldStyle(.roundedBorder)
			
			TextField("password", text: $handler.password)
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
		handler: SSHHandler(username: "root", password: "root")
	)
}
