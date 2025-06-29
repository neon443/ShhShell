//
//  SessionsView.swift
//  ShhShell
//
//  Created by neon443 on 29/06/2025.
//

import SwiftUI
import SwiftTerm

struct SessionsListView: View {
	@ObservedObject var handler: SSHHandler
	@ObservedObject var hostsManager: HostsManager
	@ObservedObject var keyManager: KeyManager
	
    var body: some View {
		Section("Sessions") {
			ForEach(TerminalViewContainer.shared.map {$0.key}, id: \.self) { key in
				SessionView(hostsManager: hostsManager, key: key)
			}
		}
    }
}

#Preview {
	SessionsListView(
		handler: SSHHandler(host: Host.debug),
		hostsManager: HostsManager(),
		keyManager: KeyManager()
	)
}
