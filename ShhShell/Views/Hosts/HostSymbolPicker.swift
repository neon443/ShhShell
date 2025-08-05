//
//  HostSymbolPicker.swift
//  ShhShell
//
//  Created by neon443 on 05/08/2025.
//

import SwiftUI

struct HostSymbolPicker: View {
	@Binding var host: Host
	
	@Environment(\.colorScheme) var cScheme
	
    var body: some View {
		ZStack {
			Rectangle()
				.foregroundStyle(cScheme == .dark ? .black : .gray)
			VStack(alignment: .center, spacing: 10) {
				ScrollView(.horizontal) {
					HStack {
						ForEach(HostSymbol.allCases, id: \.self) { symbol in
							ZStack {
								if host.symbol == symbol {
									Rectangle()
										.fill(.gray.opacity(0.5))
										.clipShape(RoundedRectangle(cornerRadius: 5))
								}
								HostSymbolPreview(symbol: symbol, label: host.label)
									.padding(10)
							}
							.transition(.opacity)
							.animation(.bouncy, value: host.symbol)
							.frame(width: 50, height: 50)
							.onTapGesture {
								withAnimation { host.symbol = symbol }
							}
						}
					}
				}
				.scrollIndicators(.visible)
				
				Divider()
				
				TextBox(label: host.label.isEmpty ? "" : "Icon Label", text: $host.label, prompt: "Icon label")
			}
			.padding(10)
		}
		.scrollDisabled(true)
    }
}

#Preview {
	HostSymbolPicker(host: .constant(Host.debug))
}
