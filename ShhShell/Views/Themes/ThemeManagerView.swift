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
	
	@State private var newTheme: Theme = Theme.defaultTheme
	@State private var showNewThemeEditor: Bool = false
	
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
					let columns: Int = max(1, Int((geo.size.width - 2*spacing) / (minColWidth + spacing)))
					let layout = Array(repeating: grid, count: columns)
					ScrollView {
						HStack {
							Text("Accent Color")
								.padding(.top)
								.padding(.horizontal)
								.font(.headline)
							Spacer()
						}
						HStack {
							AnsiPickerView(hostsManager: hostsManager)
//								.frame(width: 400, height: 100)
							Spacer()
						}
						.padding(.horizontal)
						
						HStack {
							Text("Your Themes")
								.padding(.horizontal)
								.padding(.vertical)
								.font(.headline)
							Spacer()
						}
						if hostsManager.themes.isEmpty {
							VStack(alignment: .leading) {
								ZStack {
									Image(systemName: "paintpalette")
										.resizable().scaledToFit()
										.symbolRenderingMode(.multicolor)
										.blur(radius: 2)
									Image(systemName: "paintpalette")
										.resizable().scaledToFit()
										.symbolRenderingMode(.multicolor)
								}
								.padding(.bottom, 10)
								.frame(width: 75, height: 75)
								Text("No themes (yet)")
									.font(.title)
									.bold()
								Text("Tap the Safari icon at the top right to find themes!")
								Text("Once you find one that you like, copy it's link and enter it here using the link button.")
							}
						} else {
							LazyVGrid(columns: layout, alignment: .center, spacing: 8) {
								ForEach($hostsManager.themes) { $theme in
									ThemeButton(hostsManager: hostsManager, theme: $theme, canModify: true)
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
								ThemeButton(hostsManager: hostsManager, theme: .constant(theme), canModify: false)
							}
						}
						.padding(.horizontal)
						.padding(.bottom)
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
						ToolbarItemGroup {
							Button() {
								UIApplication.shared.open(URL(string: "https://iterm2colorschemes.com")!)
							} label: {
								Label("Browse", systemImage: "safari")
							}
							Button() {
								showAlert.toggle()
							} label: {
								Label("URL", systemImage: "link")
							}
						}
						
						if #available(iOS 19, *) {
							ToolbarSpacer()
						}
						
						ToolbarItem() {
							Button() {
								newTheme = Theme.defaultTheme
								showNewThemeEditor = true
							} label: {
								Label("New", systemImage: "plus")
							}
						}
					}
					.navigationDestination(isPresented: $showNewThemeEditor) {
						ThemeEditorView(hostsManager: hostsManager, theme: $newTheme)
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
