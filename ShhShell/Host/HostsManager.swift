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
	@Published var selectedTheme: Theme = Theme.defaultTheme
	@Published var selectedAnsi: Int = 1
	
	@Published var fonts: [UIFont] = []
	@Published var selectedFont: String = "Menlo"
	
	var tint: SwiftUI.Color {
		selectedTheme.ansi[selectedAnsi].suiColor
	}
	
	init() {
		loadHosts()
		loadThemes()
		loadFonts()
	}
	
	func loadFonts() {
		var customFonts: [UIFont] = []
		for family in UIFont.familyNames.sorted() {
			if FontFamilies.allCasesRaw.contains(family) {
				guard let family = FontFamilies(rawValue: family) else { return }
				guard let customFont = UIFont(name: family.description, size: UIFont.systemFontSize) else { return }
				customFonts.append(customFont)
			}
		}
		self.fonts = customFonts
		
		self.selectedFont = userDefaults.string(forKey: "selectedFontName") ?? "Menlo"
	}
	
	func selectFont(_ fontName: String) {
		guard fonts.map({ $0.familyName }).contains(fontName) else { return }
		withAnimation { selectedFont = fontName }
		saveFonts()
	}
	
	func saveFonts() {
		userDefaults.set(selectedFont, forKey: "selectedFontName")
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
		print(themes.count)
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
		withAnimation { selectedAnsi = ansi }
		saveThemes()
	}
	
	func selectTheme(_ selectedTheme: Theme) {
		withAnimation { self.selectedTheme = selectedTheme }
		saveThemes()
	}
	
	func isThemeSelected(_ themeInQuestion: Theme) -> Bool {
		return themeInQuestion == self.selectedTheme
	}
	
	func updateTheme(_ theme: Theme) {
		guard let index = themes.firstIndex(where: { $0.id == theme.id }) else { return }
		themes[index] = theme
		saveThemes()
	}
	
	func renameTheme(_ theme: Theme?, to newName: String) {
		guard let theme else { return }
		guard theme.name != newName else { return }
		guard let index = themes.firstIndex(where: {$0.id == theme.id}) else { return }
		var newTheme = themes[index]
		newTheme.name = newName
		newTheme.id = UUID().uuidString
		withAnimation { themes[index] = newTheme }
		saveThemes()
	}
	
	func deleteTheme(_ themeToDel: Theme) {
		guard let index = themes.firstIndex(where: {$0 == themeToDel}) else { return }
		themes.remove(at: index)
		saveThemes()
	}
	
	@MainActor
	func importTheme(data: Data?, fromUrl: URL? = nil) {
		guard let data else { return }
		guard var theme = Theme.decodeTheme(data: data) else { return }
		theme.name = fromUrl?.lastPathComponent.replacingOccurrences(of: ".itermcolors", with: "") ?? ""
		self.themes.append(theme)
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
		let oldID = updatedHost.id
		
		if let index = hosts.firstIndex(where: { $0.id == updatedHost.id }) {
			var updateHostWithNewID = updatedHost
			updateHostWithNewID.id = UUID()
			withAnimation { hosts[index] = updateHostWithNewID }
			
			updateHostWithNewID.id = oldID
			withAnimation { hosts[index] = updateHostWithNewID }
			saveHosts()
		}
	}
	
	func duplicateHost(_ hostToDup: Host) {
		var hostNewID = hostToDup
		hostNewID.id = UUID()
		if let index = hosts.firstIndex(where: { $0 == hostToDup }) {
			hosts.insert(hostNewID, at: index+1)
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
	
	func addHostIfNeeded(_ hostToAdd: Host) {
		if !hosts.contains(hostToAdd) {
			hosts.append(hostToAdd)
		}
	}
	
	func removeHost(_ host: Host) {
		if let index = hosts.firstIndex(where: { $0.id == host.id }) {
			let _ = withAnimation { hosts.remove(at: index) }
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
