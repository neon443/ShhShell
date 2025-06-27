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
	
	@Published var savedHosts: [Host] = []
	@Published var themes: [Theme] = []
	
	init() {
		loadSavedHosts()
		loadThemes()
	}
	
	
	func loadThemes() {
		guard let dataTheme = userDefaults.data(forKey: "themes") else { return }
		guard let dataThemeNames = userDefaults.data(forKey: "themeNames") else { return }
		
		guard let decodedThemes = try? JSONDecoder().decode([ThemeCodable].self, from: dataTheme) else { return }
		guard let decodedThemeNames = try? JSONDecoder().decode([String].self, from: dataThemeNames) else { return }
		
		for index in 0..<decodedThemes.count {
			guard let encoded = try? JSONEncoder().encode(decodedThemes[index]) else { return }
			guard let synthedTheme = Theme.decodeTheme(name: decodedThemeNames[index], data: encoded) else { return }
			self.themes.append(synthedTheme)
		}
	}
	
	func downloadTheme(fromUrl: URL?) {
		guard let fromUrl else { return }
		let task = URLSession.shared.dataTask(with: fromUrl) { data, response, error in
			guard let data else { return }
			let name = fromUrl.lastPathComponent.replacingOccurrences(of: ".itermcolors", with: "")
			DispatchQueue.main.async {
				self.importTheme(name: name, data: data)
			}
		}
		
		task.resume()
	}
	
	@MainActor
	func importTheme(name: String, data: Data?) {
		guard let data else { return }
		guard let theme = Theme.decodeTheme(name: name, data: data) else { return }
		self.themes.append(theme)
		saveThemes()
	}
	
	func saveThemes() {
		let encoder = JSONEncoder()
		guard let encodedThemes = try? encoder.encode(themes.map({$0.themeCodable})) else { return }
		guard let encodedThemeNames = try? encoder.encode(themes.map{$0.name}) else { return }
		
		userDefaults.set(encodedThemes, forKey: "themes")
		userDefaults.set(encodedThemeNames, forKey: "themeNames")
		userDefaults.synchronize()
	}
	
	func getHostIndexMatching(_ hostSearchingFor: Host) -> Int? {
		if let index = savedHosts.firstIndex(where: { $0.id == hostSearchingFor.id }) {
			return index
		} else {
			return nil
		}
	}
	
	func getHostMatching(_ HostSearchingFor: Host) -> Host? {
		guard let index = getHostIndexMatching(HostSearchingFor) else { return nil }
		return savedHosts[index]
	}
	
	func updateHost(_ updatedHost: Host) {
		let oldID = updatedHost.id
		
		if let index = savedHosts.firstIndex(where: { $0.id == updatedHost.id }) {
			var updateHostWithNewID = updatedHost
			updateHostWithNewID.id = UUID()
			withAnimation { savedHosts[index] = updateHostWithNewID }
			
			updateHostWithNewID.id = oldID
			withAnimation { savedHosts[index] = updateHostWithNewID }
			saveSavedHosts()
		}
	}
	
	func duplicateHost(_ hostToDup: Host) {
		var hostNewID = hostToDup
		hostNewID.id = UUID()
		if let index = savedHosts.firstIndex(where: { $0 == hostToDup }) {
			savedHosts.insert(hostNewID, at: index+1)
		}
	}
	
	func makeLabel(forHost: Host) -> String {
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
		savedHosts.move(fromOffsets: from, toOffset: to)
		saveSavedHosts()
	}
	
	func loadSavedHosts() {
		userDefaults.synchronize()
		let decoder = JSONDecoder()
		guard let data = userDefaults.data(forKey: "savedHosts") else { return }
		
		if let decoded = try? decoder.decode([Host].self, from: data) {
			self.savedHosts = decoded
		}
	}
	
	func saveSavedHosts() {
		let encoder = JSONEncoder()
		if let encoded = try? encoder.encode(savedHosts) {
			userDefaults.set(encoded, forKey: "savedHosts")
			userDefaults.synchronize()
		}
	}
	
	func removeHost(_ host: Host) {
		if let index = savedHosts.firstIndex(where: { $0.id == host.id }) {
			let _ = withAnimation { savedHosts.remove(at: index) }
			saveSavedHosts()
		}
	}
	
	func getKeys() -> [Keypair] {
		var result: [Keypair] = []
		for host in savedHosts {
			if result.contains(where: { $0 == Keypair(publicKey: host.publicKey, privateKey: host.privateKey)}) {
				
			} else {
				result.append(Keypair(publicKey: host.publicKey, privateKey: host.privateKey))
			}
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
