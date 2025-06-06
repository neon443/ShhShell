//
//  ContentView.swift
//  ShhShell
//
//  Created by neon443 on 02/06/2025.
//

import SwiftUI

struct ContentView: View {
	@ObservedObject var handler: SSHHandler
	
    var body: some View {
        VStack {
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

			Button("connect & auth") {
				handler.connect()
				handler.authWithPw()
			}
			Button("disconnect & free") {
				handler.disconnect()
			}
			Button("testExec") {
				handler.testExec()
			}
        }
    }
}

#Preview {
    ContentView(
		handler: SSHHandler(username: "root", password: "root")
	)
}
