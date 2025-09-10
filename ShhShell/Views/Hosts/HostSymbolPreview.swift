//
//  HostSymbolPreview.swift
//  ShhShell
//
//  Created by neon443 on 26/06/2025.
//

import SwiftUI

struct HostSymbolPreview: View {
	@State var symbol: HostSymbol
	@State var label: String
	@State var horizontal: Bool = false
	
	var body: some View {
		if horizontal {
			HStack(alignment: .center, spacing: 5) {
				symbol.image
					.resizable().scaledToFit()
					.symbolRenderingMode(.monochrome)
				if !label.isEmpty {
					Text(label)
				}
			}
		} else {
			ZStack(alignment: .center) {
				symbol.image
					.resizable().scaledToFit()
					.symbolRenderingMode(.monochrome)
					.blur(radius: 1)
				symbol.image
					.resizable().scaledToFit()
					.symbolRenderingMode(.monochrome)
				Text(label)
					.font(.headline)
					.offset(symbol.offset)
			}
		}
	}
}

#Preview {
	HostSymbolPreview(symbol: HostSymbol.desktopcomputer, label: "lo0")
		.border(.red)
	HostSymbolPreview(symbol: HostSymbol.laptopcomputer, label: "lo1", horizontal: true)
		.border(.blue)
}
