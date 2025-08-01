//
//  FontManagerView.swift
//  ShhShell
//
//  Created by neon443 on 06/07/2025.
//

import SwiftUI

struct FontManagerView: View {
	@ObservedObject var hostsManager: HostsManager
	
	@State var testLine: String = "the lazy brown fox jumps over the lazy dog"
	
	var body: some View {
		List {
			VStack {
				HStack {
					Text("Font Size")
					Spacer()
					Text("\(Int(hostsManager.fontSize))")
						.contentTransition(.numericText())
				}
				.padding(.horizontal)
				
				Slider(value: $hostsManager.fontSize, in: 1...20, step: 1) {
					
				} minimumValueLabel: {
					Label("", systemImage: "textformat.size.smaller")
				} maximumValueLabel: {
					Label("", systemImage: "textformat.size.larger")
				} onEditingChanged: { bool in
					hostsManager.saveFonts()
				}
			}
			
			ForEach(FontFamilies.allCasesRaw, id: \.self) { fontName in
				let selected = hostsManager.selectedFont == fontName
				Button() {
					hostsManager.selectFont(fontName)
				} label: {
					VStack(alignment: .leading, spacing: 5) {
						Text(fontName)
							.foregroundStyle(.gray)
						HStack {
							Circle()
								.frame(width: 20)
								.opacity(selected ? 1 : 0)
								.foregroundStyle(.green)
								.animation(.spring, value: selected)
								.transition(.scale)
							Text(testLine)
								.font(.custom(fontName, size: 15))
								.bold(selected)
								.opacity(selected ? 1 : 0.8)
						}
					}
				}
			}
			
			Section("Test String") {
				TextEditor(text: $testLine)
					.fixedSize()
			}
		}
	}
}

#Preview {
	FontManagerView(hostsManager: HostsManager())
}
