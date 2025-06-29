//
//  SessionView.swift
//  ShhShell
//
//  Created by neon443 on 29/06/2025.
//

import SwiftUI

struct SessionView: View {
	@ObservedObject var hostsManager: HostsManager
	@State var key: UUID
	@State var shellPresented: Bool = false
	
    var body: some View {
		Text(key.uuidString)
			.onTapGesture {
				shellPresented.toggle()
			}
			.fullScreenCover(isPresented: $shellPresented) {
				ShellView(
					handler: TerminalViewContainer.shared[key]!.handler,
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
