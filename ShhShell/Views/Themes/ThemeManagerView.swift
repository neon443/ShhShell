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
	
	@State var showRenameAlert: Bool = false
	@State var themeToRename: Theme?
	@State var rename: String = ""
	
	var minColWidth: CGFloat {150}
	var spacing: CGFloat {8}
	var grid: GridItem {
		GridItem(
			.flexible(minimum: minColWidth, maximum: 250),
			spacing: spacing,
			alignment: .center
		)
	}
	
	var body: some View {
		ZStack {
			hostsManager.selectedTheme.background.suiColor.opacity(0.7)
				.ignoresSafeArea(.all)
			GeometryReader { geo in
				VStack {
					AnsiPickerView(hostsManager: hostsManager)
					
					let columns: Int = max(1, Int((geo.size.width - 2*spacing) / (minColWidth + spacing)))
					let layout = Array(repeating: grid, count: columns)
					ScrollView {
						if hostsManager.themes.isEmpty {
							VStack(alignment: .leading) {
								Image(systemName: "paintpalette")
									.resizable().scaledToFit()
									.symbolRenderingMode(.multicolor)
									.frame(width: 50)
								Text("No themes (yet)")
									.font(.title)
									.padding(.vertical, 10)
									.bold()
								Text("Tap the Safari icon at the top right to find themes!")
								Text("Once you find one that you like, copy it's link and enter it here using the link button.")
							}
						} else {
							LazyVGrid(columns: layout, alignment: .center, spacing: 8) {
								ForEach(hostsManager.themes) { theme in
									ThemePreview(hostsManager: hostsManager, theme: theme, canModify: true)
								}
							}
							.padding(.horizontal)
							.animation(.default, value: hostsManager.themes)
						}
						
						HStack {
							Text("Built-in Themes")
								.padding(.top)
								.padding(.horizontal)
								.font(.headline)
							Spacer()
						}
						LazyVGrid(columns: layout, alignment: .center, spacing: 8) {
							ForEach(Theme.builtinThemes) { theme in
								ThemePreview(hostsManager: hostsManager, theme: theme, canModify: false)
							}
						}
						.padding(.horizontal)
						.animation(.default, value: hostsManager.themes)
					}
					.navigationTitle("Themes")
					.alert("Enter URL", isPresented: $showAlert) {
						TextField("", text: $importURL, prompt: Text("URL"))
						Button("Cancel") {}
						Button() {
							hostsManager.downloadTheme(fromUrl: URL(string: importURL))
							importURL = ""
						} label: {
							Label("Import", systemImage: "square.and.arrow.down")
								.bold()
						}
					}
					.toolbar {
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
}

#Preview {
	NavigationStack {
		ThemeManagerView(
			hostsManager: HostsManager(),
			importURL: "https://raw.githubusercontent.com/mbadolato/iTerm2-Color-Schemes/master/schemes/catppuccin-frappe.itermcolors"
		)
	}
}
