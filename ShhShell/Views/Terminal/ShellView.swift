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
	
	@State var jellyLoc: (x: Int, y: Int) = (0, 0)
	@State var jellySize: CGSize = CGSize(width: 0, height: 0)
	@State var jellyShow: Bool = true
	
	@Environment(\.dismiss) var dismiss
	
	var body: some View {
		NavigationStack {
			ZStack {
				hostsManager.selectedTheme.background.suiColor
					.ignoresSafeArea(.all)
				
				ZStack(alignment: .topLeading) {
					TerminalController(handler: handler, hostsManager: hostsManager)
						.brightness(hostsManager.settings.filter == .crt ? 0.2 : 0.0)
						.onAppear {
							let timer = Timer(timeInterval: 0.1, repeats: true) { timer in
								DispatchQueue.main.async {
									let terminalView = container.sessions[handler.sessionID ?? UUID()]?.terminalView
									let delegate = terminalView?.terminalDelegate as? SSHTerminalDelegate
									terminalView?.getTerminal().hideCursor()
									jellyLoc = terminalView?.getTerminal().getCursorLocation() ?? jellyLoc
									jellySize = delegate?.computeFontDimensions() ?? jellySize
//									jellyShow = terminalView?.getTerminal().buffer.isCursorInViewPort ?? jellyShow
								}
							}
							RunLoop.main.add(timer, forMode: .common)
						}
					
					Rectangle()
						.frame(width: jellySize.width, height: jellySize.height)
						.offset(
							x: CGFloat(jellyLoc.x)*jellySize.width,
							y: CGFloat(jellyLoc.y)*jellySize.height
						)
						.opacity(jellyShow ? 1 : 0)
						.animation(.spring, value: jellyLoc.x)
						.animation(.spring, value: jellyLoc.y)
					
					if hostsManager.settings.filter == .crt {
						CRTView()
							.opacity(0.75)
							.brightness(-0.2)
							.blendMode(.overlay)
							.allowsHitTesting(false)
					}
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
