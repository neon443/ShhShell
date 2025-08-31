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
	
	@State var cursorPos: (x: Int, y: Int) = (0, 0)
	var jellyLoc: CGSize {
		var offset = CGSize(width: cursorPos.x, height: cursorPos.y)
		offset.width *= cellDimension.width
		offset.height *= cellDimension.height
		switch hostsManager.settings.cursorType.cursorShape {
		case .block, .bar:
			fallthrough
		case .underline:
			offset.height += cellDimension.height * 0.8
		}
		return offset
	}
	
	@State var cellDimension: CGSize = CGSize(width: 0, height: 0)
	var jellySize: CGSize {
		var cellDimension: CGSize = cellDimension
		switch hostsManager.settings.cursorType.cursorShape {
		case .block:
			fallthrough
		case .bar:
			cellDimension.width *= 0.3
		case .underline:
			cellDimension.height *= 0.2
		}
		return cellDimension
	}
	
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
									cursorPos = terminalView?.getTerminal().getCursorLocation() ?? cursorPos
									cellDimension = delegate?.computeFontDimensions() ?? cellDimension
//									jellyShow = terminalView?.getTerminal().buffer.isCursorInViewPort ?? jellyShow
								}
							}
//							RunLoop.main.add(timer, forMode: .common)
						}
					
//					Rectangle()
//						.frame(width: jellySize.width, height: jellySize.height)
//						.offset(
//							x: jellyLoc.width,
//							y: jellyLoc.height
//						)
//						.opacity(jellyShow ? 1 : 0)
//						.animation(.spring(duration: 0.2, bounce: 0.6), value: cursorPos.x)
//						.animation(.spring(duration: 0.2, bounce: 0.6), value: cursorPos.y)
//						.animation(.spring(duration: 0.2, bounce: 0.6), value: jellyLoc.width)
//						.animation(.spring(duration: 0.2, bounce: 0.6), value: jellyLoc.height)
//						.animation(.spring(duration: 0.2, bounce: 0.6), value: jellySize.width)
//						.animation(.spring(duration: 0.2, bounce: 0.6), value: jellySize.height)
					
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
