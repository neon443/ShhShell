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
	
	@State var showSnippetPicker: Bool = false
	
	@Environment(\.dismiss) var dismiss
	
	var foreground: Color {
		let selectedTheme = hostsManager.selectedTheme
		let foreground = selectedTheme.foreground
		let background = selectedTheme.background
		
		if selectedTheme.ansi[hostsManager.selectedAnsi].luminance > 0.5 {
			if foreground.luminance > 0.5 {
				return background.suiColor
			} else {
				return foreground.suiColor
			}
		} else {
			if foreground.luminance > 0.5 {
				return foreground.suiColor
			} else {
				return background.suiColor
			}
		}
	}
	var background: Color { hostsManager.selectedTheme.background.suiColor }
	
	var body: some View {
		ZStack {
			background
				.ignoresSafeArea(.all)
			GeometryReader { geo in
				VStack(spacing: 0) {
					let oneTabWidth = max(60, (geo.size.width)/CGFloat(container.sessionIDs.count))
					
					HStack(alignment: .center, spacing: 10) {
						Button() {
							for session in container.sessions.values {
								session.handler.disconnect()
							}
							dismiss()
						} label: {
							TrafficLightRed()
						}
						Button() {
							dismiss()
						} label: {
							TrafficLightYellow()
						}
						Spacer()
						VStack {
							Text(container.sessions[selectedID ?? UUID()]?.handler.title ?? handler?.title ?? "")
								.bold()
								.foregroundStyle(foreground)
								.monospaced()
								.contentTransition(.numericText())
							if container.sessionIDs.count == 1 {
								Text(container.sessions[selectedID ?? UUID()]?.handler.host.description ?? handler?.host.description ?? "")
									.bold()
									.foregroundStyle(foreground)
									.monospaced()
									.font(.caption2)
							}
						}
						Spacer()
						Button() {
							showSnippetPicker.toggle()
						} label: {
							Image(systemName: "paperclip")
						}
						.foregroundStyle(foreground)
						.sheet(isPresented: $showSnippetPicker) {
							SnippetPicker(hostsManager: hostsManager) {
								container.sessions[selectedID ?? UUID()]?.handler.writeToChannel($0.content)
							}
						}
					}
					.padding(.horizontal, 10)
					.padding(.vertical, 10)
					.background(hostsManager.tint, ignoresSafeAreaEdges: .all)
					.frame(height: 40)
					
					if container.sessionIDs.count > 1 {
						ScrollView(.horizontal, showsIndicators: false) {
							HStack(spacing: 0) {
								ForEach(container.sessionIDs, id: \.self) { id in
									let selected: Bool = selectedID == id
									ZStack {
										Rectangle()
											.fill(selected ? hostsManager.tint : background)
										HStack {
											Spacer()
											VStack {
												if !selected {
													Text(container.sessions[id]!.handler.title)
														.monospaced()
														.foregroundStyle(selected ? foreground : hostsManager.tint)
														.opacity(0.7)
														.font(.callout)
												}
												Text(container.sessions[id]!.handler.host.description)
													.foregroundStyle(selected ? foreground : hostsManager.tint)
													.opacity(selected ? 1 : 0.7)
													.monospaced()
													.bold(selected)
													.font(.caption2)
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
							ShellView(
								handler: handler,
								hostsManager: hostsManager
							)
							.onAppear {
								if selectedID == nil {
									selectedID = handler.sessionID
								}
							}
						} else {
							Text("No Session")
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
