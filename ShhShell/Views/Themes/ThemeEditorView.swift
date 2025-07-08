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
	
	//	@State var theme: Theme
	@State var themeCodable: ThemeCodable
	
	init(hostsManager: HostsManager, theme: Theme) {
		self.hostsManager = hostsManager
		//		self.theme = theme
		self.themeCodable = theme.themeCodable
	}
	
	var body: some View {
		NavigationStack {
			List {
				TextField(
					"Name",
					text: Binding(get: { themeCodable.name ?? "Theme" }, set: { themeCodable.name = $0 })
				)
				.textFieldStyle(.roundedBorder)
				
				ThemePreview(hostsManager: HostsManager(), theme: themeCodable.toTheme(), canModify: false)
					.id(themeCodable)
				
				Group {
					HStack {
						Rectangle()
							.fill(themeCodable.foreground.suiColor)
						Text("Foreground")
						Spacer()
						ColorPicker("", selection: $themeCodable.foreground.suiColor, supportsOpacity: false)
							.labelsHidden()
					}
					Rectangle()
						.fill(themeCodable.background.suiColor)
					Rectangle()
						.fill(themeCodable.bold.suiColor)
					Rectangle()
						.fill(themeCodable.cursor.suiColor)
					Rectangle()
						.fill(themeCodable.cursorText.suiColor)
					Rectangle()
						.fill(themeCodable.selection.suiColor)
					Rectangle()
						.fill(themeCodable.selectedText.suiColor)
				}
				
				ForEach(0...1, id: \.self) { row in
					HStack {
						ForEach(1...8, id: \.self) { col in
							let index = (col + (row * 8)) - 1
							ColorPicker("Ansi \(index+1)", selection: $themeCodable[ansiIndex: index], supportsOpacity: false)
						}
					}
				}
			}
			.navigationTitle("Edit Theme")
			.toolbar {
				Button() {
					hostsManager.updateTheme(themeCodable.toTheme())
				} label: {
					Label("Done", systemImage: "checkmark")
				}
			}
		}
	}
}

#Preview {
	ThemeEditorView(hostsManager: HostsManager(), theme: Theme.defaultTheme)
}
