//
//  AnsiPickerView.swift
//  ShhShell
//
//  Created by neon443 on 03/07/2025.
//

import SwiftUI

struct AnsiPickerView: View {
	@ObservedObject var hostsManager: HostsManager
	
	@Environment(\.colorScheme) var colorScheme
	
	var body: some View {
		ZStack(alignment: .center) {
			RoundedRectangle(cornerRadius: 15)
				.foregroundStyle(hostsManager.selectedTheme.foreground.suiColor.opacity(0.5))
			VStack(spacing: 0) {
				ForEach(0...1, id: \.self) { row in
					HStack(spacing: 0) {
						ForEach(1...8, id: \.self) { col in
							let index = (col+(row*8))-1
							var isSelected: Bool { hostsManager.selectedAnsi == index }
							ZStack {
								Rectangle()
									.fill(hostsManager.selectedTheme.background.suiColor)
								RoundedRectangle(cornerRadius: isSelected ? 5 : 0)
									.fill(hostsManager.selectedTheme.ansi[index].suiColor)
									.padding(isSelected ? 5 : 0)
									.shadow(
										color: colorScheme == .dark ? .white : .black,
										radius: isSelected ? 2 : 0
									)
									.onTapGesture {
										hostsManager.selectAnsi(index)
									}
							}
							.frame(minWidth: 20, minHeight: 20)
							.aspectRatio(1, contentMode: .fit)
						}
					}
				}
			}
			.aspectRatio(4, contentMode: .fit)
			.clipShape(RoundedRectangle(cornerRadius: 10))
			.padding(5)
		}
	}
}

#Preview {
	AnsiPickerView(hostsManager: HostsManager())
}
