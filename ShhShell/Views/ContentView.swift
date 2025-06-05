//
//  ContentView.swift
//  ShhShell
//
//  Created by neon443 on 02/06/2025.
//

import SwiftUI

struct ContentView: View {
	var sshHandler = SSHHandler()
	
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
			Button("go") {
				sshHandler.testExec()
			}
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
