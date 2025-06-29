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
	
	let grid: GridItem = GridItem(
		.fixed(90),
		spacing: 8,
		alignment: .center
	)
	
	var body: some View {
		NavigationStack {
			List {
				Section("Your Themes") {
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
						ScrollView(.horizontal) {
							LazyHGrid(rows: [grid, grid], alignment: .center, spacing: 8) {
								ForEach(hostsManager.themes) { theme in
									ThemePreview(hostsManager: hostsManager, theme: theme)
										.contextMenu {
											Button() {
												themeToRename = theme
												rename = theme.name
												showRenameAlert.toggle()
											} label: {
												Label("Rename", systemImage: "pencil")
											}
											Button(role: .destructive) {
												hostsManager.deleteTheme(theme)
											} label: {
												Label("Delete", systemImage: "trash")
											}
										}
								}
							}
							.animation(.default, value: hostsManager.themes)
							.alert("", isPresented: $showRenameAlert) {
								TextField("", text: $rename)
								Button("OK") {
									hostsManager.renameTheme(themeToRename, to: rename)
									rename = ""
								}
							}
						}
						.fixedSize(horizontal: false, vertical: true)
						.scrollIndicators(.hidden)
					}
				}
				
				Section("Builtin Themes") {
					ScrollView(.horizontal) {
						LazyHGrid(rows: [grid, grid], alignment: .center, spacing: 8) {
							ForEach(Theme.builtinThemes) { theme in
								ThemePreview(hostsManager: hostsManager, theme: theme)
							}
						}
					}
					.scrollIndicators(.hidden)
					.fixedSize(horizontal: false, vertical: true)
				}
			}
			.navigationTitle("Themes")
			.alert("Enter URL", isPresented: $showAlert) {
				TextField("", text: $importURL, prompt: Text("URL"))
				Button() {
					hostsManager.downloadTheme(fromUrl: URL(string: importURL))
					importURL = ""
				} label: {
					Label("Import", systemImage: "square.and.arrow.down")
				}
				Button("Cancel") {}
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

#Preview {
	ThemeManagerView(
		hostsManager: HostsManager(),
		importURL: "https://raw.githubusercontent.com/mbadolato/iTerm2-Color-Schemes/master/schemes/catppuccin-frappe.itermcolors"
	)
}
