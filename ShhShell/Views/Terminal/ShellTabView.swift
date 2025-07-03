//
//  ShellTabView.swift
//  ShhShell
//
//  Created by neon443 on 03/07/2025.
//

import SwiftUI

struct ShellTabView: View {
	@ObservedObject var handler: SSHHandler
	@ObservedObject var hostsManager: HostsManager
	
	@ObservedObject var container = TerminalViewContainer.shared
	@State var selectedID: UUID?
	
	@Environment(\.dismiss) var dismiss
	
    var body: some View {
		GeometryReader { geo in
			VStack {
				let oneTabWidth = max(60, geo.size.width/CGFloat(container.sessionIDs.count))
				ScrollView(.horizontal, showsIndicators: false) {
					HStack(spacing: 0) {
						ForEach(container.sessionIDs, id: \.self) { id in
							ZStack {
								Rectangle()
									.fill(selectedID == id ? .orange : .gray)
									.opacity(0.5)
								Text(container.sessions[id]!.handler.host.description)
									.frame(width: oneTabWidth)
							}
							.ignoresSafeArea(.all)
							.onTapGesture {
								withAnimation { selectedID = id }
							}
						}
					}
				}
				.frame(height: 30)
				.onAppear {
					if selectedID == nil {
						selectedID = handler.sessionID
					}
				}
				
				if let selectedID,
				   let session = container.sessions[selectedID] {
					ShellView(
						handler: session.handler,
						hostsManager: hostsManager
					)
					.onDisappear {
						if !checkShell(session.handler.state) {
							if let lastSession = container.sessionIDs.last {
								withAnimation { self.selectedID = lastSession }
							} else {
								dismiss()
							}
						}
					}
					.id(selectedID)
					.transition(.opacity)
				} else {
					ShellView(handler: handler, hostsManager: hostsManager)
				}
			}
		}
    }
}

#Preview {
	ShellTabView(
		handler: SSHHandler(host: Host.blank, keyManager: nil),
		hostsManager: HostsManager()
	)
}
