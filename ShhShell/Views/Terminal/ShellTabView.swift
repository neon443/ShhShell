//
//  ShellTabView.swift
//  ShhShell
//
//  Created by neon443 on 03/07/2025.
//

import SwiftUI

struct ShellTabView: View {
	@State var handler: SSHHandler?
	@ObservedObject var hostsManager: HostsManager
	
	@ObservedObject var container = TerminalViewContainer.shared
	@State var selectedID: UUID?
	
	@Environment(\.dismiss) var dismiss
	
	var foreground: Color { hostsManager.selectedTheme.foreground.suiColor }
	var ansi7: Color { hostsManager.selectedTheme.ansi[6].suiColor.opacity(0.7) }
	var background: Color { hostsManager.selectedTheme.background.suiColor }
	
	var body: some View {
		ZStack {
			background
				.ignoresSafeArea(.all)
			GeometryReader { geo in
				VStack {
					let oneTabWidth = max(60, (geo.size.width)/CGFloat(container.sessionIDs.count))
					
					HStack(alignment: .center, spacing: 10) {
						Button() {
							for session in container.sessions.values {
								session.handler.disconnect()
							}
						} label: {
							TrafficLightRed()
						}
						Button() {
							dismiss()
						} label: {
							TrafficLightYellow()
						}
						Button() {
							print("get out of fullscreen idk??")
						} label: {
							TrafficLightGreen()
						}
						Spacer()
						Text(container.sessions[selectedID ?? UUID()]?.handler.title ?? "title")
						Spacer()
					}
					.frame(height: 30)
					.padding(.horizontal)
					
					HStack(alignment: .center, spacing: 0) {
						ScrollView(.horizontal, showsIndicators: false) {
							HStack(spacing: 0) {
								ForEach(container.sessionIDs, id: \.self) { id in
									let selected: Bool = selectedID == id
									ZStack {
										Rectangle()
											.fill(selected ? ansi7 : background)
										HStack {
											Spacer()
											VStack {
												Text(container.sessions[id]!.handler.title)
													.monospaced()
													.foregroundStyle(foreground)
													.bold(selected)
												Text(container.sessions[id]!.handler.host.description)
													.foregroundStyle(foreground.opacity(0.7))
													.monospaced()
													.font(.caption)
											}
											Spacer()
										}
									}
									.frame(width: oneTabWidth)
									.onTapGesture {
										withAnimation { selectedID = id }
									}
								}
							}
						}
					}
					.frame(height: 30)
					.onAppear {
						if selectedID == nil {
							if let handler {
								selectedID = handler.sessionID
							} else {
								dismiss()
							}
						}
					}
					
					//the acc terminal lol
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
						if let handler {
							ShellView(handler: handler, hostsManager: hostsManager)
						} else {
							Text("No SSH Handler")
						}
					}
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
