//
//  SessionView.swift
//  ShhShell
//
//  Created by neon443 on 29/06/2025.
//

import SwiftUI

struct SessionView: View {
	@ObservedObject var hostsManager: HostsManager
	@ObservedObject var container = TerminalViewContainer.shared
	
	@State var key: UUID
	@State var shellPresented: Bool = false
	
	var host: Host {
		container.sessions[key]?.handler.host ?? Host.blank
	}
	
	var body: some View {
		Button() {
			shellPresented.toggle()
		} label: {
			HStack {
				Image(systemName: "apple.terminal")
					.resizable().scaledToFit()
					.frame(width: 40, height: 40)
					.foregroundStyle(.terminalGreen)
				SymbolPreview(symbol: host.symbol, label: host.label)
					.frame(width: 40, height: 40)
				Text(hostsManager.makeLabel(forHost: host))
			}
		}
		.fullScreenCover(isPresented: $shellPresented) {
			ShellView(
				handler: container.sessions[key]?.handler ?? SSHHandler(host: Host.blank),
				hostsManager: hostsManager
			)
		}
	}
}

#Preview {
	SessionView(
		hostsManager: HostsManager(),
		key: UUID()
	)
}
