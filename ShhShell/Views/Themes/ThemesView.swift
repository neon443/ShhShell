//
//  ThemesView.swift
//  ShhShell
//
//  Created by neon443 on 27/06/2025.
//

import SwiftUI

struct ThemesView: View {
	@ObservedObject var hostsManager: HostsManager
	
	@State var showAlert: Bool = false
	@State var importURL: String = ""
	@State var toImportName: String = ""
	
    var body: some View {
		NavigationStack {
			List {
				ScrollView(.horizontal) {
					HStack {
						ForEach(hostsManager.themes) { theme in
							ZStack(alignment: .center) {
								RoundedRectangle(cornerRadius: 10)
									.fill(theme.background.suiColor)
								VStack(alignment: .leading) {
									Text(theme.name)
										.foregroundStyle(theme.foreground.suiColor)
									HStack {
										ForEach(0..<8, id: \.self) { index in
											Rectangle()
												.frame(width: 12, height: 12)
												.foregroundStyle(theme.ansi[index].suiColor)
										}
									}
									HStack {
										ForEach(8..<16, id: \.self) { index in
											Rectangle()
												.frame(width: 12, height: 12)
												.foregroundStyle(theme.ansi[index].suiColor)
										}
									}
								}
							}
							.frame(width: 100, height: 100)
						}
					}
				}
				.scrollIndicators(.hidden)
			}
			.alert("Enter URL of your theme", isPresented: $showAlert) {
				TextField("", text: $importURL, prompt: Text("from iterm2colorschemes.com"))
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

#Preview {
    ThemesView(hostsManager: HostsManager())
}
