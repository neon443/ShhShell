//
//  ThemeButton.swift
//  ShhShell
//
//  Created by neon443 on 27/06/2025.
//

import SwiftUI

struct ThemeButton: View {
	@ObservedObject var hostsManager: HostsManager
	@Binding var theme: Theme
	@State var canModify: Bool
	
	@State private var showRenameAlert: Bool = false
	@State private var rename: String = ""
	
	var isSelected: Bool {
		return hostsManager.isThemeSelected(theme)
	}
	
	var body: some View {
		let padding: CGFloat = 10
		let innerPadding: CGFloat = 5
		let outerR: CGFloat = 15
		var paletteR: CGFloat {
			outerR-padding
		}
		var selectionR: CGFloat {
			outerR-innerPadding
		}
		
		ZStack(alignment: .center) {
			Rectangle()
				.fill(Color.accentColor)
				.opacity(isSelected ? 1 : 0)
			Rectangle()
				.fill(theme.background.suiColor)
				.clipShape(
					RoundedRectangle(
						cornerRadius: isSelected ? selectionR : 0
					)
				)
				.padding(isSelected ? innerPadding : 0)
			
			VStack {
				Text(theme.name)
					.foregroundStyle(theme.foreground.suiColor)
					.font(.headline)
					.lineLimit(1)
				
				Spacer()
				
				VStack(spacing: 0) {
					HStack(spacing: 0) {
						ForEach(0..<8, id: \.self) { index in
							Rectangle()
								.aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)
								.foregroundStyle(theme.ansi[index].suiColor)
						}
					}
					
					HStack(spacing: 0) {
						ForEach(8..<16, id: \.self) { index in
							Rectangle()
								.aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)
								.foregroundStyle(theme.ansi[index].suiColor)
						}
					}
				}
				.clipShape(RoundedRectangle(cornerRadius: paletteR))
			}
			.padding(padding)
		}
		.onTapGesture {
			hostsManager.selectTheme(theme)
		}
		.animation(.spring, value: isSelected)
		.clipShape(RoundedRectangle(cornerRadius: outerR))
		.contextMenu {
			if canModify {
				NavigationLink {
					ThemeEditorView(hostsManager: hostsManager, theme: $theme)
				} label: {
					Label("Edit", systemImage: "pencil")
				}
				Button() {
					rename = theme.name
					showRenameAlert.toggle()
				} label: {
					Label("Rename", systemImage: "text.cursor")
				}
				Divider()
			}
			
			Button() {
				hostsManager.duplicateTheme(theme)
			} label: {
				Label("Duplicate", systemImage: "square.filled.on.square")
			}
			
			if canModify {
				Divider()
				Button(role: .destructive) {
					hostsManager.deleteTheme(theme)
				} label: {
					Label("Delete", systemImage: "trash")
				}
			}
		}
		.alert("Rename \(theme.name)", isPresented: $showRenameAlert) {
			TextField("", text: $rename)
			Button("OK") {
				hostsManager.renameTheme(theme, to: rename)
				rename = ""
			}
		}
	}
}

#Preview {
	ThemeButton(
		hostsManager: HostsManager(),
		theme: .constant(Theme.defaultTheme),
		canModify: true
	)
	.border(Color.red)
}
