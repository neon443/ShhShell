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
//			List {
//			TextField("Name", text: $themeCodable.name)
			
			ThemePreview(hostsManager: HostsManager(), theme: themeCodable.toTheme(), canModify: false)
				.id(themeCodable)
			
			Group {
				Rectangle()
					.fill(themeCodable.foreground.stColor.suiColor)
				Rectangle()
					.fill(themeCodable.background.stColor.suiColor)
				Rectangle()
					.fill(themeCodable.bold.stColor.suiColor)
				Rectangle()
					.fill(themeCodable.cursor.stColor.suiColor)
				Rectangle()
					.fill(themeCodable.cursorText.stColor.suiColor)
				Rectangle()
					.fill(themeCodable.selection.stColor.suiColor)
				Rectangle()
					.fill(themeCodable.selectedText.stColor.suiColor)
			}
			.frame(width: 100)
			.toolbar {
				Button() {
					
				} label: {
					Label("Donw", systemImage: "checkmark")
				}
			}
			
				ForEach(0...1, id: \.self) { row in
					HStack {
						ForEach(1...8, id: \.self) { col in
							let index = (col + (row * 8)) - 1
							ColorPicker("Ansi \(index+1)", selection: $themeCodable[ansiIndex: index])
						}
					}
				}
//			}
		}
	}
}

#Preview {
	ThemeEditorView(hostsManager: HostsManager(), theme: Theme.defaultTheme)
}
