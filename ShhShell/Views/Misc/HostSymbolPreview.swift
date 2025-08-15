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
	@State var small: Bool = false
	
	var body: some View {
		if small {
			HStack(alignment: .center, spacing: 5) {
				if !label.isEmpty {
					Text(label)
						.font(.headline)
				}
				symbol.image
					.resizable().scaledToFit()
					.symbolRenderingMode(.monochrome)
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
				if !label.isEmpty {
					Text(label)
						.font(.headline)
						.offset(symbol.offset)
				}
			}
		}
	}
}

#Preview {
	HostSymbolPreview(symbol: HostSymbol.desktopcomputer, label: "lo0")
}
