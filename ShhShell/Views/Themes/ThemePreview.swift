//
//  ThemePreview.swift
//  ShhShell
//
//  Created by neon443 on 09/07/2025.
//

import SwiftUI

struct ThemePreview: View {
	@Binding var theme: Theme
	@State var padding: CGFloat
	@State var paletteR: CGFloat
	
    var body: some View {
		VStack {
			Text(theme.name)
				.foregroundStyle(theme.foreground.suiColor)
				.font(.headline)
				.lineLimit(1)
			
			Spacer()
			
			VStack(spacing: 0) {
				HStack(spacing: 0) {
					ForEach(0..<8, id: \.self) { index in
						Rectangle()
							.aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)
							.foregroundStyle(theme.ansi[index].suiColor)
					}
				}
				
				HStack(spacing: 0) {
					ForEach(8..<16, id: \.self) { index in
						Rectangle()
							.aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)
							.foregroundStyle(theme.ansi[index].suiColor)
					}
				}
			}
			.clipShape(RoundedRectangle(cornerRadius: paletteR))
		}
		.padding(padding)
    }
}

#Preview {
	ThemePreview(theme: .constant(Theme.defaultTheme), padding: 5, paletteR: 10)
}
