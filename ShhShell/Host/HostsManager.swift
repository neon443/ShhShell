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
	
	/// get the index of a matching host in saved hosts
	/// - Parameter host: input a host
	/// - Returns: if an item in savedHosts has a matching uuid to the parameter, it returns the index
	/// else returns nil
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
		if let index = savedHosts.firstIndex(where: { $0.id == updatedHost.id }) {
			savedHosts[index] = updatedHost
			saveSavedHosts()
		}
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
