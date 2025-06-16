//
//  TerminalView.swift
//  ShhShell
//
//  Created by neon443 on 09/06/2025.
//

import SwiftUI
import Runestone

struct TerminalView: View {
	@ObservedObject var handler: SSHHandler
	
    var body: some View {
		HStack {
			Button("read from server") {
				handler.readFromChannel()
			}
			.fixedSize()
			Spacer()
			Button("disconnect") {
				handler.disconnect()
				withAnimation { handler.testSuceeded = false }
				withAnimation { handler.connected = false }
			}
			.disabled(!handler.connected)
		}
		TextViewController(text: $handler.terminal)
    }
}

#Preview {
    TerminalView(handler: SSHHandler(host: debugHost()))
}
