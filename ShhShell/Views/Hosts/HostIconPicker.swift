//
//  HostIconPicker.swift
//  ShhShell
//
//  Created by neon443 on 05/08/2025.
//

import SwiftUI

struct HostIconPicker: View {
	@Binding var host: Host
	
    var body: some View {
		List {
			ScrollView(.horizontal) {
				HStack {
					ForEach(HostSymbol.allCases, id: \.self) { symbol in
						ZStack {
							if host.symbol == symbol {
								RoundedRectangle(cornerRadius: 10)
									.fill(.gray.opacity(0.5))
							}
							HostSymbolPreview(symbol: symbol, label: host.label)
								.padding(5)
						}
						.frame(width: 50, height: 50)
						.onTapGesture {
							withAnimation { host.symbol = symbol }
						}
					}
				}
			}
			TextBox(label: "Icon Text", text: $host.label, prompt: "")
		}
    }
}

#Preview {
	HostIconPicker(host: .constant(Host.debug))
}
