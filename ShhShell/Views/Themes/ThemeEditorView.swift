//
//  ThemeEditorView.swift
//  ShhShell
//
//  Created by neon443 on 07/07/2025.
//

import SwiftUI
import SwiftTerm

struct ThemeEditorView: View {
	@State var theme: Theme
	
	var body: some View {
		NavigationStack {
//			List {
				ForEach(0...1, id: \.self) { row in
					HStack {
						ForEach(1...8, id: \.self) { col in
							let index = (col + (row * 8)) - 1
							ColorPicker(
								selection: Binding(
									get: { theme.ansi[index].suiColor },
									set: { newValue in
										let cc = SwiftTerm.Color(newValue).colorCodable
										theme.ansi[index] = cc.stColor
									}
								)
							) {
								RoundedRectangle(cornerRadius: 5)
									.fill(theme.ansi[index].suiColor)
							}
						}
					}
				}
//			}
		}
	}
}

#Preview {
	ThemeEditorView(theme: Theme.defaultTheme)
}
