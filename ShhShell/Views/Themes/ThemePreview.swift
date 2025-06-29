//
//  ThemePreview.swift
//  ShhShell
//
//  Created by neon443 on 27/06/2025.
//

import SwiftUI

struct ThemePreview: View {
	@ObservedObject var hostsManager: HostsManager
	@State var theme: Theme
	
    var body: some View {
		ZStack(alignment: .center) {
			Rectangle()
				.fill(Color.accentColor)
			
			Rectangle()
				.fill(theme.background.suiColor)
				.frame(
					width: hostsManager.isThemeSelected(theme) ? 190 : 200,
					height: hostsManager.isThemeSelected(theme) ? 80 : 90
				)
				.clipShape(
					RoundedRectangle(
						cornerRadius: hostsManager.isThemeSelected(theme) ? 5 : 10
					)
				)
			VStack(alignment: .leading) {
				Text(theme.name)
					.foregroundStyle(theme.foreground.suiColor)
					.font(.headline)
				Spacer()
				HStack(spacing: 8) {
					ForEach(0..<8, id: \.self) { index in
						RoundedRectangle(cornerRadius: 2)
							.frame(width: 16, height: 16)
							.foregroundStyle(theme.ansi[index].suiColor)
					}
				}
				HStack(spacing: 8) {
					ForEach(8..<16, id: \.self) { index in
						RoundedRectangle(cornerRadius: 2)
							.frame(width: 16, height: 16)
							.foregroundStyle(theme.ansi[index].suiColor)
					}
				}
			}
			.padding(8)
		}
		.frame(maxWidth: 200, maxHeight: 90)
		.clipShape(RoundedRectangle(cornerRadius: 10))
		.onTapGesture {
			hostsManager.selectTheme(theme)
		}
    }
}

#Preview {
	let url = URL(string:  "https://raw.githubusercontent.com/mbadolato/iTerm2-Color-Schemes/master/schemes/catppuccin-frappe.itermcolors")!
	let data = try! Data(contentsOf: url)
	
	ThemePreview(
		hostsManager: HostsManager(),
		theme: Theme.decodeTheme(data: data)!
	)
}
