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
	
	init() {
		loadHosts()
		loadThemes()
	}
	
	func loadThemes() {
		userDefaults.synchronize()
		guard let dataTheme = userDefaults.data(forKey: "themes") else { return }
		
		guard let decodedThemes = try? JSONDecoder().decode([ThemeCodable].self, from: dataTheme) else { return }
		
		for index in 0..<decodedThemes.count {
			guard let encoded = try? JSONEncoder().encode(decodedThemes[index]) else { return }
			guard let synthedTheme = Theme.decodeTheme(data: encoded) else { return }
			self.themes.append(synthedTheme)
		}
		
		
		guard let dataSelTheme = userDefaults.data(forKey: "selectedTheme") else { return }
		guard let decodedSelTheme = Theme.decodeTheme(data: dataSelTheme) else { return }
		//name doesnt matter
		self.selectedTheme = decodedSelTheme
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
	
	func selectTheme(_ selectedTheme: Theme) {
		withAnimation { self.selectedTheme = selectedTheme }
		saveThemes()
	}
	
	func isThemeSelected(_ themeInQuestion: Theme) -> Bool {
		return themeInQuestion == self.selectedTheme
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
	
	func saveThemes() {
		let encoder = JSONEncoder()
		// map the theme to themecodable
		guard let encodedThemes = try? encoder.encode(themes.map({$0.themeCodable})) else { return }
		userDefaults.set(encodedThemes, forKey: "themes")
		
		guard let encodedSelectedTheme = try? encoder.encode(selectedTheme.themeCodable) else { return }
		userDefaults.set(encodedSelectedTheme, forKey: "selectedTheme")
		userDefaults.synchronize()
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
	
	func makeLabel(forHost: Host?) -> String {
		guard let forHost else { return "" }
		if forHost.name.isEmpty && forHost.address.isEmpty {
			return forHost.id.uuidString
		} else if forHost.name.isEmpty {
			return forHost.address
		} else if forHost.address.isEmpty {
			return forHost.name
		} else {
			return forHost.name
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
	
	func getKeys() -> [Keypair] {
		var result: [Keypair] = []
		for host in hosts {
			guard let publicKey = host.publicKey else { continue }
			guard let privateKey = host.privateKey else { continue }
			let keypair = Keypair(type: .rsa, name: UUID().uuidString, publicKey: publicKey, privateKey: privateKey)
			if !result.contains(keypair) {
				result.append(keypair)
			}
		}
		return result
	}
	
	func getHostsKeysUsedOn(_ keys: [Keypair]) -> [Host] {
		var result: [Host] = []
		for key in keys {
			let hosts = hosts.filter({
				$0.publicKey == key.publicKey &&
				$0.privateKey == key.privateKey
			})
			result += hosts
		}
		return result
	}
	
	func authWithBiometrics() async -> Bool {
		let context = LAContext()
		var error: NSError?
		guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
			return false
		}
		
		let reason = "Authenticate yourself to view private keys"
		return await withCheckedContinuation { continuation in
			context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, _ in
				continuation.resume(returning: success)
			}
		}
	}
}
