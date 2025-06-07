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
	@State var testSucceded: Bool = false
	
    var body: some View {
        VStack {
			Text(connected ? "connected" : "not connected")
				.foregroundStyle(connected ? .green : .red)
			Text(handler.authorized ? "authorized" : "unauthorized")
				.foregroundStyle(handler.authorized ? .green : .red)
			if testSucceded {
				Image(systemName: "checkmark.circle")
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
			Button("disconnect") {
				handler.disconnect()
				withAnimation { testSucceded = false }
				withAnimation { connected = false}
			}
			Button("run a test command") {
				withAnimation {
					if handler.testExec() {
						testSucceded = true
					} else {
						testSucceded = false
					}
				}
			}
        }
    }
}

#Preview {
    ContentView(
		handler: SSHHandler(username: "root", password: "root")
	)
}
