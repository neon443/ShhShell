//
//  SymbolPreview.swift
//  ShhShell
//
//  Created by neon443 on 26/06/2025.
//

import SwiftUI

struct SymbolPreview: View {
	@State var symbol: HostSymbol
	@State var label: String
	
    var body: some View {
		ZStack(alignment: .center) {
			if symbol.isCustom {
				Image(symbol.sf)
					.resizable().scaledToFit()
					.symbolRenderingMode(.monochrome)
			} else {
				Image(systemName: symbol.sf)
					.resizable().scaledToFit()
					.symbolRenderingMode(.monochrome)
			}
			Text(label)
				.font(.headline)
				.offset(symbol.offset)
		}
    }
}

#Preview {
	SymbolPreview(symbol: HostSymbol.desktopcomputer, label: "lo0")
}
