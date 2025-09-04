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
						ZStack {
							if hostsManager.settings.cursorType.cursorShape == .block {
								Rectangle()
									.frame(width: 20, height: 40)
							} else if hostsManager.settings.cursorType.cursorShape == .bar {
								Rectangle()
									.frame(width: 4, height: 40)
							} else if hostsManager.settings.cursorType.cursorShape == .underline {
								Rectangle()
									.frame(width: 20, height: 4)
									.padding(.top, 36)
							}
						}
						//						.padding(.leading, 248)
						.id(hostsManager.settings.cursorType.cursorShape)
						.animation(.default, value: hostsManager.settings.cursorType.cursorShape)
						.transition(.opacity)
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
					
					Picker("Shape", selection: $hostsManager.settings.cursorType.cursorShape) {
						ForEach(CursorShape.allCases, id: \.self) { type in
							Text(type.description).tag(type)
						}
					}
					.pickerStyle(.inline)
					.labelsHidden()
					
					Picker("Animation Type", selection: $hostsManager.settings.cursorAnimations.type) {
						ForEach(CursorAnimationType.allCases, id: \.self) { animType in
							Text(animType.description).tag(animType)
						}
					}
					
					Slider(value: $hostsManager.settings.cursorAnimations.length, in: 0.05...0.5, step: 0.05) {
						Label("Speed", systemImage: "gauge.with.dots.needle.67percent")
					}
					.disabled(hostsManager.settings.cursorAnimations.type == .none)
					
					Slider(value: $hostsManager.settings.cursorAnimations.stretchMultiplier, in: 0.25...2, step: 0.25) {
						Label("Stretch Multiplier", systemImage: "multiply")
					}
					.disabled(hostsManager.settings.cursorAnimations.type != .stretchAndMove)
				}
				
				Section("Keepalive") {
					Toggle("location persistence", systemImage: "location.fill", isOn: $hostsManager.settings.locationPersist)
						.onChange(of: hostsManager.settings.locationPersist) { _ in
							if hostsManager.settings.locationPersist && !Backgrounder.shared.checkPermsStatus() {
								Backgrounder.shared.requestPerms()
							}
						}
					Toggle("keep screen awake", systemImage: "cup.and.saucer.fill", isOn: $hostsManager.settings.caffeinate)
				}
				
				Section("Bell") {
					Toggle("bell sound", systemImage: "bell.and.waves.left.and.right", isOn: $hostsManager.settings.bellSound)
					Toggle("bell haptic",systemImage: "iphone.radiowaves.left.and.right", isOn: $hostsManager.settings.bellHaptic)
				}
				
				
				Section("Terminal Filter") {
					if #unavailable(iOS 17), hostsManager.settings.filter == .crt {
						Label("iOS 17 Required", systemImage: "exclamationmark.triangle.fill")
							.foregroundStyle(.yellow)
							.transition(.opacity)
					}
					Picker("", selection: $hostsManager.settings.filter) {
						ForEach(TerminalFilter.allCases, id: \.self) { filter in
							Text(filter.description).tag(filter)
						}
					}
					.pickerStyle(.inline)
					.labelsHidden()
				}
				.animation(.spring, value: hostsManager.settings.filter)
				
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
			.listStyle(.insetGrouped)
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
