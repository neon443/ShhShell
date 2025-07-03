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
	
	@State var shellView: ShellView? = nil
	
    var body: some View {
		GeometryReader { geo in
			VStack {
				let oneTabWidth = max(60, geo.size.width/CGFloat(container.sessionIDs.count))
				ScrollView(.horizontal, showsIndicators: false) {
					HStack(spacing: 0) {
						ForEach(container.sessionIDs, id: \.self) { id in
							Text(container.sessions[id]!.handler.host.description)
								.frame(width: oneTabWidth)
								.background(.blue)
								.onTapGesture {
									selectedID = id
									if let session = container.sessions[selectedID!] {
										shellView = ShellView(handler: session.handler, hostsManager: hostsManager)
									}
								}
						}
					}
				}
				.onAppear {
					if shellView == nil {
						shellView = ShellView(handler: handler, hostsManager: hostsManager)
					}
				}
				.frame(height: 30)
				if let shellView {
					shellView
						.id(selectedID)
				} else {
					Text("no shellview")
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
