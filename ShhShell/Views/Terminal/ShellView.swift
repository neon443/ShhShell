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
	
	@State var startTime: Date = .now
	
	var body: some View {
		NavigationStack {
			let time = startTime.timeIntervalSinceNow
			ZStack {
				hostsManager.selectedTheme.background.suiColor
					.ignoresSafeArea(.all)
				
				TerminalController(handler: handler, hostsManager: hostsManager)
//					.visualEffect { content, proxy in
//						content
//							.layerEffect(
//							ShaderLibrary.crt(
//								.float2(proxy.size),
//								.float(time)
//							),
//							maxSampleOffset: .zero
//						)
//					}
//					.blendMode(.screen)
					.overlay {
						if hostsManager.settings.filter == .crt {
							CRTView()
								.opacity(0.75)
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
