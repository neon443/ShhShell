//
//  ShellTabView.swift
//  ShhShell
//
//  Created by neon443 on 03/07/2025.
//

import SwiftUI
import SwiftTerm

struct ShellTabView: View {
	@State var handler: SSHHandler?
	@ObservedObject var hostsManager: HostsManager
	@ObservedObject var keyManager: KeyManager
	
	@ObservedObject var container = TerminalViewContainer.shared
	@State var selectedID: UUID?
	var selectedHandler: SSHHandler {
		guard let selectedID, let contained = container.sessions[selectedID] else {
			guard let handler else { return SSHHandler(host: Host.blank, keyManager: nil) }
			return handler
		}
		return contained.handler
	}
	
	@State private var showSnippetPicker: Bool = false
	
	@Environment(\.dismiss) var dismiss
	
	var foreground: SwiftUI.Color {
		let selectedTheme = hostsManager.selectedTheme
		let fg = selectedTheme.foreground
		let bg = selectedTheme.background
		let ansi = selectedTheme.ansi[hostsManager.selectedAnsi]
		var result: SwiftTerm.Color
		
		if fg.luminanceRatio(with: ansi) > bg.luminanceRatio(with: ansi) {
			result = fg
		} else {
			result = bg
		}
		
		guard result.luminanceRatio(with: ansi) > 4.5 else {
			return ansi.luminance > 0.5 ? .black : .white
		}
		return result.suiColor
	}
	var background: SwiftUI.Color { hostsManager.selectedTheme.background.suiColor }
	
	var body: some View {
		ZStack {
			background
				.ignoresSafeArea(.all)
			VStack(spacing: 0) {
				//header
				HStack(alignment: .center, spacing: 10) {
					Button() {
						dismiss()
						for session in container.sessions.values {
							session.handler.disconnect()
							session.handler.cleanup()
						}
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
					
					if selectedHandler.state != .shellOpen {
						Button() {
							withAnimation { selectedHandler.forceDismissDisconnectedAlert = false }
						} label: {
							Image(systemName: "wifi.exclamationmark")
								.resizable().scaledToFit()
								.frame(width: 20, height: 20)
						}
						.foregroundStyle(foreground)
						.id(selectedID)
					}
					
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
								let selected: Bool = id == selectedHandler.sessionID ?? UUID()
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
//				Group {
//					if selectedID != nil {
						ShellView(
							handler: selectedHandler,
							hostsManager: hostsManager
						)
//					}
//				}
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
			}
		}
	}
}

#Preview {
	ShellTabView(
		handler: SSHHandler(host: Host.blank, keyManager: nil),
		hostsManager: HostsManager(),
		keyManager: KeyManager()
	)
}
