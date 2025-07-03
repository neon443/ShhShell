//
//  AnsiPickerView.swift
//  ShhShell
//
//  Created by neon443 on 03/07/2025.
//

import SwiftUI

struct AnsiPickerView: View {
	@ObservedObject var hostsManager: HostsManager
	
	var body: some View {
		GeometryReader { geo in
			VStack(spacing: 0) {
				ForEach(0...1, id: \.self) { row in
					HStack(spacing: 0) {
						ForEach(1...8, id: \.self) { col in
							let index = (col+(row*8))-1
							var isSelected: Bool { hostsManager.selectedAnsi == index }
							ZStack {
								Rectangle()
									.fill(Color.blue)
								Rectangle()
									.fill(hostsManager.selectedTheme.ansi[index].suiColor)
									.padding(isSelected ? 5 : 0)
									.clipShape(
										RoundedRectangle(
											cornerRadius: isSelected ? 10 : 0
										)
									)
									.onTapGesture {
										hostsManager.selectAnsi(index)
									}
							}
						}
					}
				}
			}
		}
		.clipShape(RoundedRectangle(cornerRadius: 15))
	}
}

#Preview {
	AnsiPickerView(hostsManager: HostsManager())
}
