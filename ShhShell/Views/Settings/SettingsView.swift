//
//  SettingsView.swift
//  ShhShell
//
//  Created by neon443 on 19/08/2025.
//

import SwiftUI

struct SettingsView: View {
	@ObservedObject var hostsManager: HostsManager
	@ObservedObject var keyManager: KeyManager
	
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
							in: 1_000...50_000,
							step: 1_000.0
						)
					}
					
					Picker("Cursor", selection: $hostsManager.settings.cursorStyle) {
						ForEach(CursorStyle.allCases, id: \.self) { type in
							Text("\(type)").tag(type)
						}
					}
					.pickerStyle(.inline)
				}
				
				Toggle("location persistence", systemImage: "location.fill", isOn: $hostsManager.settings.locationPersist)
				
				Toggle("bell sound", systemImage: "bell.and.waves.left.and.right", isOn: $hostsManager.settings.bellSound)
				Toggle("bell haptic",systemImage: "iphone.homebutton.radiowaves.left.and.right", isOn: $hostsManager.settings.bellHaptic)
				
				Toggle("keep screen awake", systemImage: "cup.and.saucer.fill", isOn: $hostsManager.settings.caffeinate)
				
				Picker("terminal filter", selection: $hostsManager.settings.filter) {
					ForEach(TerminalFilter.allCases, id: \.self) { filter in
						Text("\(filter)").tag(filter)
					}
				}
				.pickerStyle(.inline)
				
				Section("App Icon") {
					HStack {
						ForEach(AppIcon.allCases, id: \.self) { icon in
							VStack(alignment: .center) {
								icon.image
									.resizable().scaledToFit()
									.frame(maxWidth: 50)
									.clipShape(RoundedRectangle(cornerRadius: 11))
								Text("\(icon)").tag(icon)
							}
							.onTapGesture {
								hostsManager.settings.appIcon = icon
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
		hostsManager: HostsManager(),
		keyManager: KeyManager()
	)
}
