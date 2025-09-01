//
//  HostsManager.swift
//  ShhShell
//
//  Created by neon443 on 20/06/2025.
//

import Foundation
import LocalAuthentication
import SwiftUI

class HostsManager: ObservableObject, @unchecked Sendable {
	private let userDefaults = NSUbiquitousKeyValueStore.default
	
	@Published var hosts: [Host] = []
	
	@Published var themes: [Theme] = []
	@Published var selectedTheme: Theme = Theme.decodeLocalTheme(fileName: "xcodeDarkHC") ?? Theme.defaultTheme
	@Published var selectedAnsi: Int = 4
	
	@Published var fonts: [UIFont] = []
	@Published var selectedFont: String = "SF Mono"
	@Published var fontSize: CGFloat = UIFont.systemFontSize
	
	@Published var snippets: [Snippet] = []
	
	@Published var history: [History] = []
	@Published var settings: AppSettings = AppSettings()
	@Published var shownOnboarding: Bool = false
	
	var tint: SwiftUI.Color {
		selectedTheme.ansi[selectedAnsi].suiColor
	}
	
	init(previews: Bool = false) {
		if previews {
			self.hosts = [Host.debug, Host.blank]
			self.themes = [Theme.defaultTheme]
			self.snippets = [Snippet(name: "kys", content: "ls\npwd\n")]
			self.history = [History(host: Host.debug, count: 3)]
			return
		}
		loadSettings()
		loadHosts()
		exportHosts()
		loadThemes()
		loadFonts()
		loadSnippets()
		loadHistory()
		self.shownOnboarding = UserDefaults.standard.bool(forKey: "shownOnboarding")
	}
	
	func setOnboarding(to newValue: Bool) {
		self.shownOnboarding = newValue
		UserDefaults.standard.set(newValue, forKey: "shownOnboarding")
	}
	
	func setAppIcon() {
		Task { @MainActor in
			guard UIApplication.shared.supportsAlternateIcons else { return }
			guard settings.appIcon.name != "regular" else {
				UIApplication.shared.setAlternateIconName(nil)
				return
			}
			UIApplication.shared.setAlternateIconName("\(settings.appIcon.name)")
		}
	}
	
	func loadSettings() {
		guard let data = userDefaults.data(forKey: "settings") else { return }
		guard let decoded = try? JSONDecoder().decode(AppSettings.self, from: data) else { return }
		self.settings = decoded
	}
	
	func saveSettings() {
		guard let encoded = try? JSONEncoder().encode(settings) else { return }
		userDefaults.set(encoded, forKey: "settings")
	}
	
	func loadHistory() {
		guard let data = userDefaults.data(forKey: "history") else { return }
		guard let decoded = try? JSONDecoder().decode([History].self, from: data) else { return }
		withAnimation { self.history = decoded }
	}
	
	func addToHistory(_ host: Host) {
		if history.last?.host == host {
			guard var lastOne = history.popLast() else { return }
			lastOne.count += 1
			lastOne.lastConnect = .now
			history.append(lastOne)
		} else {
			history.append(History(host: host, count: 1))
		}
		saveHistory()
	}
	
	func saveHistory() {
		let data = try? JSONEncoder().encode(history)
		userDefaults.set(data, forKey: "history")
	}
	
	func removeFromHistory(_ toRemove: History) {
		history.removeAll(where: { $0.id == toRemove.id })
		saveHistory()
	}
	
	func addSnippet(_ toAdd: Snippet) {
		snippets.append(toAdd)
		saveSnippets()
	}
	
	func duplicateSnippet(_ snip: Snippet) {
		guard let index = snippets.firstIndex(where: { $0.id == snip.id }) else { return }
		withAnimation { snippets.insert(snip, at: index+1) }
	}
	
	func deleteSnippet(_ toDel: Snippet) {
		guard let index = snippets.firstIndex(where: { $0.id == toDel.id }) else { return }
		snippets.remove(at: index)
		saveSnippets()
	}
	
	func loadSnippets() {
		userDefaults.synchronize()
		guard let data = userDefaults.data(forKey: "snippets") else { return }
		guard let decoded = try? JSONDecoder().decode([Snippet].self, from: data) else { return }
		withAnimation { self.snippets = decoded }
	}
	
	func saveSnippets() {
		guard let encoded = try? JSONEncoder().encode(snippets) else { return }
		userDefaults.set(encoded, forKey: "snippets")
		userDefaults.synchronize()
	}
	
	func loadFonts() {
		var customFonts: [UIFont] = []
		for family in UIFont.familyNames.sorted() {
			if FontFamilies.allCasesRaw.contains(family) {
				guard let family = FontFamilies(rawValue: family) else { return }
				guard let customFont = UIFont(name: family.description, size: fontSize) else { return }
				customFonts.append(customFont)
			}
		}
		self.fonts = customFonts
		
		userDefaults.synchronize()
		self.selectedFont = userDefaults.string(forKey: "selectedFontName") ?? "SF Mono"
		self.fontSize = CGFloat(userDefaults.double(forKey: "fontSize"))
		if self.fontSize == 0 {
			self.fontSize = 12
		}
	}
	
	func selectFont(_ fontName: String) {
		guard fonts.map({ $0.familyName }).contains(fontName) else { return }
		withAnimation { selectedFont = fontName }
		saveFonts()
	}
	
	func saveFonts() {
		userDefaults.set(selectedFont, forKey: "selectedFontName")
		userDefaults.set(fontSize, forKey: "fontSize")
		userDefaults.synchronize()
	}
	
	func loadThemes() {
		userDefaults.synchronize()
		guard let dataTheme = userDefaults.data(forKey: "themes") else { return }
		
		guard let decodedThemes = try? JSONDecoder().decode([ThemeCodable].self, from: dataTheme) else { return }
		
		self.themes = []
		for index in 0..<decodedThemes.count {
			guard let encoded = try? JSONEncoder().encode(decodedThemes[index]) else { return }
			guard let synthedTheme = Theme.decodeTheme(data: encoded) else { return }
			self.themes.append(synthedTheme)
		}
		
		guard let dataSelTheme = userDefaults.data(forKey: "selectedTheme") else { return }
		guard let decodedSelTheme = Theme.decodeTheme(data: dataSelTheme) else { return }
		//name doesnt matter
		self.selectedTheme = decodedSelTheme
		
		selectedAnsi = Int(userDefaults.longLong(forKey: "selectedAnsi"))
	}
	
	func saveThemes() {
		let encoder = JSONEncoder()
		// map the theme to themecodable
		guard let encodedThemes = try? encoder.encode(themes.map({$0.themeCodable})) else { return }
		userDefaults.set(encodedThemes, forKey: "themes")
		
		guard let encodedSelectedTheme = try? encoder.encode(selectedTheme.themeCodable) else { return }
		userDefaults.set(encodedSelectedTheme, forKey: "selectedTheme")
		
		userDefaults.set(Int64(selectedAnsi), forKey: "selectedAnsi")
		userDefaults.synchronize()
		loadThemes()
	}
	
	func downloadTheme(fromUrl: URL?) {
		guard let fromUrl else { return }
		let task = URLSession.shared.dataTask(with: fromUrl) { data, response, error in
			guard let data else { return }
			DispatchQueue.main.async {
				self.importTheme(data: data, fromUrl: fromUrl)
			}
		}
		
		task.resume()
	}
	
	func selectAnsi(_ ansi: Int) {
		withAnimation(.bouncy) { selectedAnsi = ansi }
		saveThemes()
	}
	
	func selectTheme(_ selectedTheme: Theme) {
		withAnimation { self.selectedTheme = selectedTheme }
		saveThemes()
	}
	
	func isThemeSelected(_ themeInQuestion: Theme) -> Bool {
		return themeInQuestion == self.selectedTheme
	}
	
	func duplicateTheme(_ theme: Theme) {
		var newTheme = theme
		newTheme.id = UUID().uuidString
		newTheme.name.append(" copy")
		if let index = themes.firstIndex(where: { $0.id == theme.id }) {
			themes.insert(newTheme, at: index+1)
		} else {
			themes.append(newTheme)
		}
		saveThemes()
	}
	
	func updateTheme(_ theme: Theme) {
		if let index = themes.firstIndex(where: { $0.id == theme.id }) {
			themes[index] = theme
			if selectedTheme.id == theme.id {
				selectedTheme = theme
			}
		} else {
			themes.append(theme)
		}
		saveThemes()
	}
	
	func renameTheme(_ theme: Theme?, to newName: String) {
		guard let theme else { return }
		guard theme.name != newName else { return }
		guard let index = themes.firstIndex(where: {$0.id == theme.id}) else { return }
		var newTheme = themes[index]
		newTheme.name = newName
		newTheme.id = UUID().uuidString
		Haptic.medium.trigger()
		withAnimation { themes[index] = newTheme }
		saveThemes()
	}
	
	func deleteTheme(_ themeToDel: Theme) {
		guard let index = themes.firstIndex(where: {$0 == themeToDel}) else { return }
		Haptic.medium.trigger()
		themes.remove(at: index)
		saveThemes()
	}
	
	@MainActor
	func importTheme(data: Data?, fromUrl: URL? = nil) {
		guard let data else { return }
		guard var theme = Theme.decodeTheme(data: data) else { return }
		theme.name = fromUrl?.lastPathComponent.replacingOccurrences(of: ".itermcolors", with: "") ?? ""
		self.themes.append(theme)
		Haptic.success.trigger()
		saveThemes()
	}
	
	func getHostIndexMatching(_ hostSearchingFor: Host) -> Int? {
		if let index = hosts.firstIndex(where: { $0.id == hostSearchingFor.id }) {
			return index
		} else {
			return nil
		}
	}
	
	func getHostMatching(_ HostSearchingFor: Host) -> Host? {
		guard let index = getHostIndexMatching(HostSearchingFor) else { return nil }
		return hosts[index]
	}
	
	func updateHost(_ updatedHost: Host) {
		var blankHost = Host.blank
		blankHost.id = updatedHost.id
		guard updatedHost != blankHost else { return }
		
		if let index = hosts.firstIndex(where: { $0.id == updatedHost.id }) {
			withAnimation { hosts[index] = updatedHost }
			saveHosts()
		} else {
			withAnimation { hosts.append(updatedHost) }
		}
		Haptic.medium.trigger()
	}
	
	func duplicateHost(_ hostToDup: Host) {
		var hostNewID = hostToDup
		hostNewID.id = UUID()
		hostNewID.name = hostToDup.description.appending(" copy")
		if let index = hosts.firstIndex(where: { $0 == hostToDup }) {
			hosts.insert(hostNewID, at: index+1)
			Haptic.medium.trigger()
		}
	}
	
	func moveHost(from: IndexSet, to: Int) {
		hosts.move(fromOffsets: from, toOffset: to)
		saveHosts()
	}
	
	func loadHosts() {
		userDefaults.synchronize()
		let decoder = JSONDecoder()
		guard let data = userDefaults.data(forKey: "savedHosts") else { return }
		
		if let decoded = try? decoder.decode([Host].self, from: data) {
			self.hosts = decoded
		}
	}
	
	func saveHosts() {
		let encoder = JSONEncoder()
		if let encoded = try? encoder.encode(hosts) {
			userDefaults.set(encoded, forKey: "savedHosts")
			userDefaults.synchronize()
		}
	}
	
	func exportHosts() {
		guard let encoded = try? JSONEncoder().encode(hosts) else { return }
		print(encoded.base64EncodedString())
	}
	
	func importHosts(_ data: Data) {
		guard let decoedd = try? JSONDecoder().decode([Host].self, from: data) else { return }
		hosts = decoedd
	}
	
	func removeHost(_ host: Host) {
		if let index = hosts.firstIndex(where: { $0.id == host.id }) {
			let _ = withAnimation { hosts.remove(at: index) }
			Haptic.medium.trigger()
			saveHosts()
		}
	}
	
	func set(keypair: Keypair, onHost: Host) {
		guard let index = hosts.firstIndex(where: { $0.id == onHost.id }) else { return }
		withAnimation { hosts[index].privateKeyID = keypair.id }
		saveHosts()
	}
	
	func unsetKeypair(onHost: Host) {
		guard let index = hosts.firstIndex(where: { $0.id == onHost.id }) else { return }
		withAnimation { hosts[index].privateKeyID = nil }
		saveHosts()
	}
	
	func hostsUsing(key: Keypair) -> [Host] {
		var result: [Host] = []
		let hosts = hosts.filter({
			$0.privateKeyID == key.id
		})
		result += hosts
		return result
	}
	
	func hostsNotUsing(key: Keypair) -> [Host] {
		var result: [Host]
		result = hosts.filter { $0.privateKeyID != key.id }
		return result
	}
}
