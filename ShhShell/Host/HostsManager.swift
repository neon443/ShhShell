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
			var updateHostWithNewID = updatedHost
			updateHostWithNewID.id = UUID()
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
