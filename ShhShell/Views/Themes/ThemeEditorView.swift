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
			hostsManager.selectedTheme.background.suiColor.opacity(0.5)
				.ignoresSafeArea(.all)
			NavigationStack {
				ZStack {
					RoundedRectangle(cornerRadius: 20)
						.foregroundStyle(theme.background.suiColor)
					VStack {
						Text(theme.name)
							.foregroundStyle(theme.foreground.suiColor)
							.font(.headline)
							.lineLimit(1)
						Spacer()
						VStack(spacing: 0) {
							ForEach(0...1, id: \.self) { row in
								HStack(spacing: 0) {
									let range = row == 0 ? 0..<8 : 8..<16
									ForEach(range, id: \.self) { col in
										Rectangle()
											.aspectRatio(1, contentMode: .fit)
											.foregroundStyle(theme.ansi[col].suiColor)
									}
								}
							}
						}
						.clipShape(RoundedRectangle(cornerRadius: 10))
					}
					.padding(10)
				}
				.fixedSize(horizontal: false, vertical: true)
				.padding(.horizontal)
				
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
				.scrollContentBackground(.hidden)
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
