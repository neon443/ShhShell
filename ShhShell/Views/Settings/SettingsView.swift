//
//  SettingsView.swift
//  ShhShell
//
//  Created by neon443 on 19/08/2025.
//

import SwiftUI
import SwiftTerm

struct SettingsView: View {
	@ObservedObject var hostsManager: HostsManager
	@ObservedObject var keyManager: KeyManager
	
	@State private var blinkCursor: Int = 0
	@State var blinkTimer: Timer?
	@State private var start = Date.now
	
	func startBlinkingIfNeeded() {
		if hostsManager.settings.cursorType.blink {
			blinkTimer?.invalidate()
			blinkTimer = nil
			blinkTimer = Timer(timeInterval: 1, repeats: true) { timer in
				Task { @MainActor in
					blinkCursor += 1
				}
			}
			RunLoop.main.add(blinkTimer!, forMode: .common)
		} else {
			blinkTimer?.invalidate()
			if blinkCursor % 2 != 0 {
				blinkCursor += 1
			}
		}
	}
	
	var body: some View {
		ZStack {
			hostsManager.selectedTheme.background.suiColor.opacity(0.7)
				.ignoresSafeArea(.all)
			List {
				Section("Shaded") {
					TimelineView(.animation) { tl in
						let time = start.distance(to: tl.date)
//						Image(systemName: "figure.walk.circle")
//							.font(.system(size: 300))
//							.foregroundStyle(.blue)
//							.distortionEffect(
//								ShaderLibrary.wave(
//									.float(time)
//								),
//								maxSampleOffset: .zero
//							)
						Image(systemName: "square.and.arrow.up")
							.font(.system(size: 300))
							.foregroundStyle(.red)
							.drawingGroup()
							.visualEffect {
								content,
								proxy in
								content.distortionEffect(
									ShaderLibrary.waveFlag(
										.float(time),
										.float2(proxy.size)
									),
									maxSampleOffset: .zero
								)
							}
							.border(.red)
					}
				}

				Section("Shaded") {
					TimelineView(.animation) { tl in
						let time = start.distance(to: tl.date)
//					Image(systemName: "figure.walk.circle")
//						.font(.system(size: 300))
//						.foregroundStyle(.blue)
//						.colorEffect(ShaderLibrary.rainbow(
//							.float(time)
//						))
					}
				}
				Section("Original") {
					Image(systemName: "figure.walk.circle")
						.font(.system(size: 300))
						.foregroundStyle(.blue)
				}
				
				Section("Terminal") {
					VStack(alignment: .leading) {
						HStack {
							Label("Scrollback", systemImage: "scroll")
							Spacer()
							Text("\(Int(hostsManager.settings.scrollback))")
								.contentTransition(.numericText())
						}
						Slider(
							value: $hostsManager.settings.scrollback,
							in: 250...10_000,
							step: 250
						)
					}
				}
					
				Section("Cursor") {
					HStack(spacing: 20) {
						Text("neon443")
							.font(.largeTitle).monospaced()
							.foregroundStyle(.terminalGreen)
						Text("~")
							.font(.largeTitle).monospaced()
							.foregroundStyle(.blue)
						Text(">")
							.font(.largeTitle).monospaced()
							.foregroundStyle(.blue)
						Group {
							switch hostsManager.settings.cursorType.cursorShape {
							case .block:
								Rectangle()
									.frame(width: 20, height: 40)
							case .bar:
								Rectangle()
									.frame(width: 4, height: 40)
							case .underline:
								Rectangle()
									.frame(width: 20, height: 4)
									.padding(.top, 36)
							}
						}
//						.padding(.leading, 248)
						.onChange(of: hostsManager.settings.cursorType.blink) { _ in
							startBlinkingIfNeeded()
						}
						.onAppear() {
							startBlinkingIfNeeded()
						}
						.opacity(blinkCursor % 2 == 0 ? 1 : 0)
						.animation(
							Animation.spring(duration: 1),
							value: blinkCursor
						)
					}
					
					Picker("Blink", selection: $hostsManager.settings.cursorType.blink) {
						Text("Blink").tag(true)
						Text("Steady").tag(false)
					}
					.pickerStyle(.segmented)
					
					Picker("", selection: $hostsManager.settings.cursorType.cursorShape) {
						ForEach(CursorShape.allCases, id: \.self) { type in
							Text(type.description).tag(type)
						}
					}
					.pickerStyle(.inline)
					.labelsHidden()
				}
				
				Toggle("location persistence", systemImage: "location.fill", isOn: $hostsManager.settings.locationPersist)
					.onChange(of: hostsManager.settings.locationPersist) { _ in
						if hostsManager.settings.locationPersist && !Backgrounder.shared.checkPermsStatus() {
							Backgrounder.shared.requestPerms()
						}
					}
				
				Toggle("bell sound", systemImage: "bell.and.waves.left.and.right", isOn: $hostsManager.settings.bellSound)
				Toggle("bell haptic",systemImage: "iphone.radiowaves.left.and.right", isOn: $hostsManager.settings.bellHaptic)
				
				Toggle("keep screen awake", systemImage: "cup.and.saucer.fill", isOn: $hostsManager.settings.caffeinate)
				
				Picker("terminal filter", selection: $hostsManager.settings.filter) {
					ForEach(TerminalFilter.allCases, id: \.self) { filter in
						Text(filter.description).tag(filter)
					}
				}
				.pickerStyle(.inline)
				
				Section("App Icon") {
					ScrollView(.horizontal) {
						HStack {
							ForEach(AppIcon.allCases, id: \.self) { icon in
								let isSelected = hostsManager.settings.appIcon == icon
								ZStack(alignment: .top) {
									RoundedRectangle(cornerRadius: 21.5)
										.foregroundStyle(.gray.opacity(0.5))
										.opacity(isSelected ? 1 : 0)
									VStack(spacing: 0) {
										icon.image
											.resizable().scaledToFit()
											.clipShape(RoundedRectangle(cornerRadius: 16.5))
											.padding(5)
										Text(icon.description).tag(icon)
											.font(.caption)
											.padding(.bottom, 5)
											.padding(.horizontal, 5)
											.multilineTextAlignment(.center)
									}
								}
								.frame(maxWidth: 85, maxHeight: 110)
								.onTapGesture {
									withAnimation {
										hostsManager.settings.appIcon = icon
										hostsManager.setAppIcon()
									}
								}
							}
						}
					}
				}
			}
			.listStyle(.sidebar)
			.scrollContentBackground(.hidden)
			.onChange(of: hostsManager.settings) { _ in
				hostsManager.saveSettings()
			}
		}
    }
}

#Preview {
	SettingsView(
		hostsManager: HostsManager(previews: true),
		keyManager: KeyManager()
	)
}
