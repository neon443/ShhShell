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
	
    var body: some View {
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

#Preview {
	HostSymbolPreview(symbol: HostSymbol.desktopcomputer, label: "lo0")
}
