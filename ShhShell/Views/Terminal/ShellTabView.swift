//
//  ShellTabView.swift
//  ShhShell
//
//  Created by neon443 on 03/07/2025.
//

import SwiftUI

struct ShellTabView: View {
	@State var handler: SSHHandler
	@ObservedObject var hostsManager: HostsManager
	
	@ObservedObject var container = TerminalViewContainer.shared
	@State var selectedID: UUID?
	var selectedHandler: SSHHandler {
		guard let selectedID, let contained = container.sessions[selectedID] else {
			return handler
		}
		return contained.handler
	}
	
	@State private var showSnippetPicker: Bool = false
	
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
			VStack(spacing: 0) {
				//header
				HStack(alignment: .center, spacing: 10) {
					Button() {
						for session in container.sessions.values {
							session.handler.disconnect()
							session.handler.cleanup()
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
						Text(selectedHandler.title)
							.bold()
							.foregroundStyle(foreground)
							.monospaced()
							.contentTransition(.numericText())
							.strikethrough(selectedHandler.state != .shellOpen)
						if container.sessionIDs.count == 1 {
							Text(selectedHandler.host.description)
								.bold()
								.foregroundStyle(foreground)
								.monospaced()
								.font(.caption2)
								.strikethrough(selectedHandler.state != .shellOpen)
						}
					}
					Spacer()
					Button() {
						showSnippetPicker.toggle()
					} label: {
						Image(systemName: "paperclip")
							.resizable().scaledToFit()
							.frame(width: 20, height: 20)
					}
					.foregroundStyle(foreground)
					.popover(isPresented: $showSnippetPicker) {
						SnippetPicker(hostsManager: hostsManager) {
							selectedHandler.writeToChannel($0.content)
						}
						.frame(minWidth: 200, minHeight: 300)
						.modifier(presentationCompactPopover())
					}
					Menu {
						Button() {
							UIPasteboard.general.string = selectedHandler.scrollback.joined()
							Haptic.success.trigger()
						} label: {
							Label("Copy Scrollback", systemImage: "document.on.document")
						}
					} label: {
						Image(systemName: "ellipsis")
							.resizable().scaledToFit()
							.frame(width: 20, height: 20)
					}
					.foregroundStyle(foreground)
				}
				.padding(.horizontal, 10)
				.padding(.vertical, 10)
				.background(hostsManager.tint, ignoresSafeAreaEdges: .all)
				.frame(height: 40)
				
				//tab strip
				if container.sessionIDs.count > 1 {
					ScrollView(.horizontal, showsIndicators: false) {
						let oneTabWidth: CGFloat = max(100, (UIScreen.main.bounds.width)/CGFloat(container.sessionIDs.count))
						HStack(spacing: 0) {
							ForEach(container.sessionIDs, id: \.self) { id in
								let selected: Bool = selectedID == id || (selectedID == nil && handler.sessionID == id)
								let thisHandler: SSHHandler = container.sessions[id]!.handler
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
													.strikethrough(thisHandler.state != .shellOpen)
											}
											Text(container.sessions[id]!.handler.host.description)
												.foregroundStyle(selected ? foreground : hostsManager.tint)
												.opacity(selected ? 1 : 0.7)
												.monospaced()
												.bold(selected)
												.font(.caption2)
												.strikethrough(thisHandler.state != .shellOpen)
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
				}
				
				//the acc terminal lol
				if let selectedID,
				   let session = container.sessions[selectedID] {
					ShellView(
						handler: session.handler,
						hostsManager: hostsManager
					)
					.onAppear {
						UIApplication.shared.isIdleTimerDisabled = hostsManager.settings.caffeinate
						if hostsManager.settings.locationPersist {
							Backgrounder.shared.startBgTracking()
						}
					}
					.onDisappear {
						UIApplication.shared.isIdleTimerDisabled = false
						if container.sessions.isEmpty {
							Backgrounder.shared.stopBgTracking()
						}
					}
					.id(selectedID)
					.transition(.opacity)
				} else {
					ShellView(
						handler: handler,
						hostsManager: hostsManager
					)
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
