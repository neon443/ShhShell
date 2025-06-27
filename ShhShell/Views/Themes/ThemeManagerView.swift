//
//  ThemesView.swift
//  ShhShell
//
//  Created by neon443 on 27/06/2025.
//

import SwiftUI

struct ThemeManagerView: View {
	@ObservedObject var hostsManager: HostsManager
	
	@State var showAlert: Bool = false
	@State var importURL: String = ""
	@State var toImportName: String = ""
	
	let grid: GridItem = GridItem(
		.fixed(90),
		spacing: 8,
		alignment: .center
	)
	
	var body: some View {
		GeometryReader { geo in
			NavigationStack {
				ScrollView(.horizontal) {
					LazyHGrid(rows: [grid, grid], alignment: .center, spacing: 8) {
						ForEach(hostsManager.themes) { theme in
							ThemePreview(theme: theme)
						}
					}
				}
				.frame(height: 160)
				.scrollIndicators(.hidden)
				.alert("Enter URL", isPresented: $showAlert) {
					TextField("", text: $importURL, prompt: Text("URL"))
					Button() {
						hostsManager.downloadTheme(fromUrl: URL(string: importURL))
						importURL = ""
					} label: {
						Label("Import", systemImage: "square.and.arrow.down")
					}
				}
				.toolbar {
					ToolbarItem(placement: .confirmationAction) {
						Button() {
							if let pasteboard = UIPasteboard().string {
								hostsManager.importTheme(name: toImportName, data: pasteboard.data(using: .utf8))
							}
						} label: {
							Label("Import", systemImage: "plus")
						}
					}
					ToolbarItem() {
						Button() {
							UIApplication.shared.open(URL(string: "https://iterm2colorschemes.com")!)
						} label: {
							Label("Open themes site", systemImage: "safari")
						}
					}
					ToolbarItem() {
						Button() {
							showAlert.toggle()
						} label: {
							Label("From URL", systemImage: "link")
						}
					}
				}
			}
		}
	}
}

#Preview {
	ThemeManagerView(
		hostsManager: HostsManager(),
		importURL: "https://raw.githubusercontent.com/mbadolato/iTerm2-Color-Schemes/master/schemes/catppuccin-frappe.itermcolors"
	)
}
