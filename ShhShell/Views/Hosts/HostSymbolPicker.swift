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
	
	var innerR: CGFloat {
		if #available(iOS 19, *) {
			return 16
		} else {
			return 3
		}
	}
	
    var body: some View {
		ZStack {
			Rectangle()
				.foregroundStyle(cScheme == .dark ? .black : .gray)
			VStack(alignment: .center, spacing: 0) {
				ScrollView(.horizontal) {
					HStack {
						ForEach(HostSymbol.allCases, id: \.self) { symbol in
							ZStack {
								if host.symbol == symbol {
									Rectangle()
										.fill(.gray.opacity(0.5))
										.clipShape(RoundedRectangle(cornerRadius: innerR))
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
					.frame(height: 50)
				}
				.scrollIndicators(.visible)
				
				Spacer()
				Divider()
				Spacer()
				
				TextBox(label: host.label.isEmpty ? "" : "Icon Label", text: $host.label, prompt: "Icon label")
			}
			.padding(10)
		}
		.preferredColorScheme(.dark)
		.scrollDisabled(true)
    }
}

#Preview {
	HostSymbolPicker(host: .constant(Host.debug))
}
