//
//  ThemePreview.swift
//  ShhShell
//
//  Created by neon443 on 27/06/2025.
//

import SwiftUI

struct ThemePreview: View {
	@State var theme: Theme
	
    var body: some View {
		ZStack(alignment: .center) {
			RoundedRectangle(cornerRadius: 5)
				.fill(theme.background.suiColor)
			VStack(alignment: .leading) {
				Text(theme.name)
					.foregroundStyle(theme.foreground.suiColor)
					.font(.headline)
				HStack {
					ForEach(0..<8, id: \.self) { index in
						Rectangle()
							.frame(width: 15, height: 15)
							.foregroundStyle(theme.ansi[index].suiColor)
					}
				}
				HStack {
					ForEach(8..<16, id: \.self) { index in
						Rectangle()
							.frame(width: 15, height: 15)
							.foregroundStyle(theme.ansi[index].suiColor)
					}
				}
			}
			.padding(5)
		}
		.fixedSize()
		.frame(maxWidth: 150, maxHeight: 80)
    }
}

#Preview {
	let url = URL(string:  "https://raw.githubusercontent.com/mbadolato/iTerm2-Color-Schemes/master/schemes/catppuccin-frappe.itermcolors")!
	let data = try! Data(contentsOf: url)
	
	ThemePreview(
		theme: Theme.decodeTheme(name: "theme", data: data)!
	)
}
