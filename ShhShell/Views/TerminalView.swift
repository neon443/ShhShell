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
	@Environment(\.dismiss) var dismiss
	
    var body: some View {
		TextViewController(text: $handler.terminal)
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("reload") {
						handler.readFromChannel()
					}
				}
				ToolbarItem(placement: .confirmationAction) {
					Button() {
						handler.disconnect()
						withAnimation { handler.testSuceeded = false }
						withAnimation { handler.connected = false }
						dismiss()
					} label: {
						Label("Exit", systemImage: "xmark.square.fill")
					}
					.disabled(!handler.connected)
				}
			}
    }
}

#Preview {
    TerminalView(handler: SSHHandler(host: debugHost()))
}
