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
		NavigationStack {
			List {
				
				Section("Preview") {
//					ThemePreview(hostsManager: HostsManager(), theme: themeCodable.toTheme(), canModify: false)
//						.id(themeCodable)
				}
				
				Section("Name") {
					TextField("Name", text: $theme.name)
					.textFieldStyle(.roundedBorder)
				}
				
				Section("Main Colors") {
					
					ColorPicker("Text", selection: $theme.foreground.suiColor, supportsOpacity: false)
						.labelsHidden()
					ColorPicker("Background", selection: $theme.background.suiColor, supportsOpacity: false)
						.labelsHidden()
					ColorPicker("Cursor", selection: $theme.cursor.suiColor, supportsOpacity: false)
						.labelsHidden()
					ColorPicker("Cusor Text", selection: $theme.cursorText.suiColor, supportsOpacity: false)
						.labelsHidden()
					ColorPicker("Bold Text", selection: $theme.bold.suiColor, supportsOpacity: false)
						.labelsHidden()
					ColorPicker("Selection", selection: $theme.selection.suiColor, supportsOpacity: false)
						.labelsHidden()
					ColorPicker("Selected Text", selection: $theme.selectedText.suiColor, supportsOpacity: false)
						.labelsHidden()
				}
				
				Section("Ansi Colors") {
					ForEach(0...1, id: \.self) { row in
						HStack {
							ForEach(1...8, id: \.self) { col in
								let index = (col + (row * 8)) - 1
								ColorPicker("", selection: $theme.ansi[index].suiColor, supportsOpacity: false)
									.labelsHidden()
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

#Preview {
	ThemeEditorView(hostsManager: HostsManager(), theme: .constant(Theme.defaultTheme))
}
