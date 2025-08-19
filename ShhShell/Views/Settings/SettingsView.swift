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
					Label("Scrollback", systemImage: "scroll")
					HStack {
						Slider(value: .constant(0), in: 1_000...50_000, step: 1_000)
						Text("hi")
					}
					
					Picker("Cursor", selection: .constant(CursorStyle.bar)) {
						ForEach(CursorStyle.allCases, id: \.self) { type in
							Text("\(type)").tag(type)
						}
					}
					
					
					
				}
				Toggle("location persistence", isOn: .constant(false))
				
				Toggle("bell sound", isOn: .constant(false))
				Toggle("bell haptic", isOn: .constant(false))
				
				Toggle("keep screen awake", isOn: .constant(false))
				
				Picker("terminal filter", selection: .constant(TerminalFilter.crt)) {
					ForEach(TerminalFilter.allCases, id: \.self) { filter in
						Text("\(filter)").tag(filter)
					}
				}
				
				Picker("appicon", selection: .constant(AppIcon.regular)) {
					ForEach(AppIcon.allCases, id: \.self) { icon in
						Text("\(icon)").tag(icon)
						icon.image
					}
				}.pickerStyle(.menu)
			}
			.listStyle(.sidebar)
			.scrollContentBackground(.hidden)
		}
    }
}

#Preview {
	SettingsView(
		hostsManager: HostsManager(),
		keyManager: KeyManager()
	)
}
