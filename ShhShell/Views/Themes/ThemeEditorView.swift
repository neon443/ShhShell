//
//  ThemeEditorView.swift
//  ShhShell
//
//  Created by neon443 on 07/07/2025.
//

import SwiftUI
import SwiftTerm

struct ThemeEditorView: View {
	@ObservedObject var hostsManager: HostsManager
	
	@Binding var theme: Theme
	
	@Environment(\.dismiss) var dismiss
	
	var body: some View {
		ZStack {
			hostsManager.selectedTheme.background.suiColor.opacity(0.7)
				.ignoresSafeArea(.all)
			NavigationStack {
				ThemeButton(hostsManager: hostsManager, theme: $theme, canModify: false)
					.id(theme)
					.padding(.bottom)
					.fixedSize(horizontal: false, vertical: true)
					.onChange(of: theme) { _ in
						print(theme)
					}
				
				List {					
					Section("Main Colors") {
						ColorPicker("Text", selection: $theme.foreground.suiColor, supportsOpacity: false)
						ColorPicker("Background", selection: $theme.background.suiColor, supportsOpacity: false)
						ColorPicker("Cursor", selection: $theme.cursor.suiColor, supportsOpacity: false)
						ColorPicker("Cusor Text", selection: $theme.cursorText.suiColor, supportsOpacity: false)
						ColorPicker("Bold Text", selection: $theme.bold.suiColor, supportsOpacity: false)
						ColorPicker("Selection", selection: $theme.selection.suiColor, supportsOpacity: false)
						ColorPicker("Selected Text", selection: $theme.selectedText.suiColor, supportsOpacity: false)
					}
					
					Section("Ansi Colors") {
						ForEach(0...1, id: \.self) { row in
							HStack {
								Spacer()
								ForEach(1...8, id: \.self) { col in
									let index = (col + (row * 8)) - 1
									ColorPicker("", selection: $theme.ansi[index].suiColor, supportsOpacity: false)
										.labelsHidden()
									Spacer()
								}
							}
						}
					}
				}
				.navigationTitle("Edit Theme")
				.navigationBarTitleDisplayMode(.inline)
				.toolbar {
					Button() {
						hostsManager.updateTheme(theme)
						dismiss()
					} label: {
						Label("Done", systemImage: "checkmark")
					}
				}
			}
		}
	}
}

#Preview {
	ThemeEditorView(hostsManager: HostsManager(), theme: .constant(Theme.defaultTheme))
}
