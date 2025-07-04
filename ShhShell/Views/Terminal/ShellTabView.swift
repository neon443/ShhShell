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
	
	var body: some View {
		GeometryReader { geo in
			VStack {
				HStack(alignment: .center, spacing: 10) {
					Button() {
						for session in container.sessions.values {
							session.handler.disconnect()
						}
					} label: {
						Image(systemName: "xmark.circle.fill")
							.resizable().scaledToFit()
							.symbolRenderingMode(.palette)
							.foregroundStyle(
								ColorCodable(red: 0.5411764706, green: 0, blue: 0).stColor.suiColor,
								.red
							)
					}
					Button() {
						dismiss()
					} label: {
						Image(systemName: "minus.circle.fill")
							.resizable().scaledToFit()
							.symbolRenderingMode(.palette)
							.foregroundStyle(
								ColorCodable(red: 0.5764705882, green: 0.5333333333, blue: 0.2784313725).stColor.suiColor,
								.yellow
							)
					}
					Spacer()
					Text(container.sessions[selectedID ?? UUID()]?.handler.title ?? "title")
					Spacer()
				}
				.frame(height: 30)
				.padding(10)
				
				let oneTabWidth = max(60, (geo.size.width-35)/CGFloat(container.sessionIDs.count))
				HStack(alignment: .center, spacing: 0) {
					ScrollView(.horizontal, showsIndicators: false) {
						HStack(spacing: 0) {
							ForEach(container.sessionIDs, id: \.self) { id in
								let selected = selectedID == id
								let foreground = hostsManager.selectedTheme.foreground.suiColor
								let ansi7 = hostsManager.selectedTheme.ansi[6].suiColor.opacity(0.7)
								let background = hostsManager.selectedTheme.background.suiColor
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
								.ignoresSafeArea(.all)
								.onTapGesture {
									withAnimation { selectedID = id }
								}
							}
						}
					}
					Button() {
						dismiss()
					} label: {
						Image(systemName: "arrow.down.right.and.arrow.up.left")
							.resizable().scaledToFit()
					}
					.buttonStyle(.plain)
					.frame(width: 30)
					.padding(.horizontal, 2.5)
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

#Preview {
	ShellTabView(
		handler: SSHHandler(host: Host.blank, keyManager: nil),
		hostsManager: HostsManager()
	)
}
