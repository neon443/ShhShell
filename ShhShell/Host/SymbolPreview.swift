//
//  SymbolPreview.swift
//  ShhShell
//
//  Created by neon443 on 26/06/2025.
//

import SwiftUI

struct SymbolPreview: View {
	@State var host: Host
	
    var body: some View {
		ZStack(alignment: .center) {
			if host.symbol.isCustom {
				Image(host.symbol.sf)
					.resizable().scaledToFit()
					.symbolRenderingMode(.monochrome)
					.padding(5)
			} else {
				Image(systemName: host.symbol.sf)
					.resizable().scaledToFit()
					.symbolRenderingMode(.monochrome)
					.padding(5)
			}
			Text(host.label)
				.font(.headline)
				.offset(host.symbol.offset)
		}
    }
}

#Preview {
	SymbolPreview(host: Host.debug)
}
