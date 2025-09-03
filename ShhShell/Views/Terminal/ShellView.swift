//
//  ShellView.swift
//  ShhShell
//
//  Created by neon443 on 22/06/2025.
//

import SwiftUI
import AudioToolbox

struct ShellView: View {
	@ObservedObject var handler: SSHHandler
	@ObservedObject var hostsManager: HostsManager
	@ObservedObject var container = TerminalViewContainer.shared
	
	@Environment(\.dismiss) var dismiss
	
	var body: some View {
		NavigationStack {
			ZStack {
				hostsManager.selectedTheme.background.suiColor
					.ignoresSafeArea(.all)
				
				ZStack(alignment: .topLeading) {
					TerminalController(handler: handler, hostsManager: hostsManager)
						.brightness(hostsManager.settings.filter == .crt ? 0.2 : 0.0)
					
					if #available(iOS 17, *), hostsManager.settings.filter == .crt {
						CRTView()
							.opacity(0.75)
							.brightness(-0.2)
							.blendMode(.overlay)
							.allowsHitTesting(false)
					}
				}
				.onAppear {
					withAnimation { handler.forceDismissDisconnectedAlert = false }
				}
				
				Group {
					Color.gray.opacity(0.2)
						.transition(.opacity)
					Image(systemName: "bell.fill")
						.foregroundStyle(
							hostsManager.selectedTheme.background.luminance > 0.5 ?
								.black : .white
						)
						.font(.largeTitle)
						.shadow(color: .black, radius: 5)
				}
				.opacity(handler.bell ? 1 : 0)
				.onChange(of: handler.bell) { _ in
					guard handler.bell else { return }
					if hostsManager.settings.bellHaptic {
						Haptic.warning.trigger()
					}
					if hostsManager.settings.bellSound {
						AudioServicesPlaySystemSound(1103)
					}
				}
				
				if handler.state != .shellOpen && !handler.forceDismissDisconnectedAlert {
					ZStack {
						RoundedRectangle(cornerRadius: 25)
							.fill(hostsManager.selectedTheme.foreground.suiColor)
							.opacity(0.5)
							.blur(radius: 2)
							.shadow(color: hostsManager.selectedTheme.foreground.suiColor, radius: 5)
						VStack {
							HStack {
								Image(systemName: "wifi.exclamationmark")
									.resizable().scaledToFit()
									.foregroundStyle(hostsManager.selectedTheme.background.suiColor)
									.frame(width: 30)
								Text("Disconnected")
									.foregroundStyle(hostsManager.selectedTheme.background.suiColor)
									.font(.title)
							}
							Button {
								try! handler.reconnect()
							} label: {
								Text("Connect")
									.foregroundStyle(hostsManager.selectedTheme.background.suiColor)
									.padding(5)
									.frame(maxWidth: .infinity)
									.background(.tint)
									.clipShape(RoundedRectangle(cornerRadius: 15))
							}
							Button {
								withAnimation { handler.forceDismissDisconnectedAlert = true }
							} label: {
								Text("Cancel")
									.foregroundStyle(hostsManager.selectedTheme.background.suiColor)
									.padding(5)
									.frame(maxWidth: .infinity)
									.background(.tint.opacity(0.5))
									.clipShape(RoundedRectangle(cornerRadius: 15))
							}
						}
						.padding(10)
					}
					.fixedSize()
					.transition(.opacity)
					.animation(.spring, value: checkShell(handler.state))
				}
			}
		}
	}
}

#Preview {
	ShellView(
		handler: SSHHandler(host: Host.debug, keyManager: nil),
		hostsManager: HostsManager()
	)
}
