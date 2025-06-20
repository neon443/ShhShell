//
//  HostsManager.swift
//  ShhShell
//
//  Created by neon443 on 20/06/2025.
//

import Foundation

class HostsManager: ObservableObject {
	private let userDefaults = NSUbiquitousKeyValueStore.default
	
	@Published var savedHosts: [Host] = []
	
	init() {
		loadSavedHosts()
	}
	
	func loadSavedHosts() {
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
}
