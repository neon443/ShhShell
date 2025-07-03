//
//  SessionView.swift
//  ShhShell
//
//  Created by neon443 on 29/06/2025.
//

import SwiftUI

struct SessionView: View {
	@ObservedObject var hostsManager: HostsManager
	@ObservedObject var keyManager: KeyManager
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
				HostSymbolPreview(symbol: host.symbol, label: host.label)
					.frame(width: 40, height: 40)
				Text(host.description)
			}
		}
		.fullScreenCover(isPresented: $shellPresented) {
			ShellTabView(handler: nil, hostsManager: hostsManager, selectedID: key)
		}
	}
}

#Preview {
	SessionView(
		hostsManager: HostsManager(),
		keyManager: KeyManager(),
		key: UUID()
	)
}
