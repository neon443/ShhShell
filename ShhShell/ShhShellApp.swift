//
//  ShhShellApp.swift
//  ShhShell
//
//  Created by neon443 on 02/06/2025.
//

import SwiftUI

@main
struct ShhShellApp: App {
	@StateObject var sshHandler: SSHHandler = SSHHandler(username: "", password: "")
	
	var body: some Scene {
		WindowGroup {
			ContentView(handler: sshHandler)
		}
	}
}
