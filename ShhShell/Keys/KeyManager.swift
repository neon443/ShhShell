//
//  KeyManager.swift
//  ShhShell
//
//  Created by neon443 on 20/06/2025.
//

import Foundation
import CryptoKit
import Security
import SwiftUI
import LocalAuthentication

class KeyManager: ObservableObject {
	private let userdefaults = NSUbiquitousKeyValueStore.default
	private let passwordStore = GenericPasswordStore()
	
	@Published var keypairs: [Keypair] = []
	var keyIDs: [UUID] {
		keypairs.map { $0.id }
	}
//	@Published var keyTypes: [UUID: KeyType] = [:]
//	@Published var keyNames: [UUID: String] = [:]
	private let baseTag = "com.neon443.ShhShell.keys".data(using: .utf8)!
	
	init() {
		loadKeypairs()
	}
	
	func loadKeypairs() {
		userdefaults.synchronize()
		guard let data = userdefaults.data(forKey: "keypairs") else { return }
		guard let decoded = try? JSONDecoder().decode([Keypair].self, from: data) else { return }
		withAnimation { self.keypairs = decoded }
		for kp in keypairs {
			guard let KeychainKeypair = getFromKeychain(kp) else { continue }
			guard let index = keypairs.firstIndex(where: { $0.id == kp.id }) else { continue }
			withAnimation { keypairs[index] = KeychainKeypair }
		}
	}
	
	func saveKeypairs() {
		guard let coded = try? JSONEncoder().encode(keypairs) else { return }
		userdefaults.set(coded, forKey: "keypairs")
		userdefaults.synchronize()
		for keypair in keypairs {
			saveToKeychain(keypair)
		}
	}
	
	func renameKey(keypair: Keypair, newName: String) {
		guard !newName.isEmpty else { return }
		let keyID = keypair.id
		guard let index = keypairs.firstIndex(where: { $0.id == keyID }) else { return }
		var keypairWithNewName = keypair
		keypairWithNewName.name = newName
		withAnimation { keypairs[index] = keypairWithNewName }
		saveKeypairs()
	}
	
	func deleteKey(_ keypair: Keypair) {
		removeFromKeycahin(keypair: keypair)
		let keyID = keypair.id
		withAnimation { keypairs.removeAll(where: { $0.id == keyID }) }
		saveKeypairs()
	}
	
	func importKey(type: KeyType, priv: String, name: String) {
		if type == .ed25519 {
			guard let importedKeypair = KeyManager.importSSHPrivkey(priv: priv) else { return }
			saveToKeychain(importedKeypair)
		} else { fatalError() }
	}
	
	func generateKey(type: KeyType, comment: String) {
		switch type {
		case .ed25519:
			let keypair = Keypair(
				type: .ed25519,
				name: comment,
				privateKey: Curve25519.Signing.PrivateKey().rawRepresentation
			)
			saveToKeychain(keypair)
		}
		loadKeypairs()
	}
	
	//MARK: keychain
	func saveToKeychain(_ keypair: Keypair) {
		switch keypair.type {
		case .ed25519:
			let curve25519 = try! Curve25519.Signing.PrivateKey(rawRepresentation: keypair.privateKey)
			let readKey: Curve25519.Signing.PrivateKey?
			readKey = try! passwordStore.readKey(account: keypair.id.uuidString)
			if readKey != nil {
				try! passwordStore.deleteKey(account: keypair.id.uuidString)
			}
			try! passwordStore.storeKey(curve25519.genericKeyRepresentation, account: keypair.id.uuidString)
		}
		if !keypairs.contains(keypair) {
			keypairs.append(keypair)
			saveKeypairs()
		}
	}
	
	func getFromKeychain(_ keypair: Keypair) -> Keypair? {
		if keypair.type == .ed25519 {
			var key: Curve25519.Signing.PrivateKey?
			key = try? passwordStore.readKey(account: keypair.id.uuidString)
			guard let key else { return nil }
			return Keypair(id: keypair.id, type: keypair.type, name: keypair.name, privateKey: key.rawRepresentation)
		} else {
			let tag = baseTag+keypair.id.uuidString.data(using: .utf8)!
			let getQuery: [String: Any] = [kSecClass as String: kSecClassKey,
										   kSecAttrApplicationTag as String: tag,
										   kSecAttrKeyType as String: kSecAttrKeyTypeEC,
										   kSecReturnRef as String: true]
			var item: CFTypeRef?
			let status = SecItemCopyMatching(getQuery as CFDictionary, &item)
			guard status == errSecSuccess else { fatalError() }
			return Keypair(
				type: keypair.type,
				name: keypair.name,
				privateKey: item as! Data
			)
		}
	}
	
	func removeFromKeycahin(keypair: Keypair) {
		if keypair.type == .ed25519 {
			do {
				try passwordStore.deleteKey(account: keypair.id.uuidString)
			} catch {
				fatalError()
			}
		}
		saveKeypairs()
	}
	
	//MARK: openssh converters/importers
	static func importSSHPubkey(pub: String) -> Data {
		let split = pub.split(separator: " ")
		guard split.count == 3 else { return Data() }
		
		var pubdata = Data(base64Encoded: String(split[1]))!
		while pubdata.count != 36 {
			removeField(&pubdata)
		}
		pubdata.removeFirst(4)
		return pubdata
	}
	
	static func makeSSHPubkey(_ keypair: Keypair) -> Data {
		var keyBlob: Data = Data()
		//key type bit
		keyBlob += encode(str: keypair.type.header)
		//base64 blob bit
		keyBlob += encode(data: keypair.publicKey)
		
		let b64key = keyBlob.base64EncodedString()
		let pubkeyline = "\(keypair.type.header) \(b64key) \(keypair.name)\n"
		return Data(pubkeyline.utf8)
	}
	
	static func importSSHPrivkey(priv: String) -> Keypair? {
		guard !priv.isEmpty else { return nil }
		var split = priv.replacingOccurrences(of: "-----BEGIN OPENSSH PRIVATE KEY-----\n", with: "")
		split = split.replacingOccurrences(of: "-----BEGIN OPENSSH PRIVATE KEY-----", with: "")
		split = split.replacingOccurrences(of: "\n-----END OPENSSH PRIVATE KEY-----\n", with: "")
		split = split.replacingOccurrences(of: "\n-----END OPENSSH PRIVATE KEY-----", with: "")
		split = split.replacingOccurrences(of: "-----END OPENSSH PRIVATE KEY-----", with: "")
		split = split.replacingOccurrences(of: "\r\n", with: "")
		split = split.replacingOccurrences(of: " ", with: "\n")
		split = split.replacingOccurrences(of: "\n", with: "")

		var dataBlob = Data(base64Encoded: split.data(using: .utf8)!)!
		dataBlob.removeFirst(15) //remove magik header
		dataBlob.removeFirst(16) //remove none noen
		dataBlob.removeFirst(4) //remove lenght header for empty data
		dataBlob.removeFirst(8) //remove empty data
		
		removeField(&dataBlob) //remove key type for pubkey str
		
		let pubkeyData = extractField(&dataBlob) //extract pubkey field
		
		dataBlob.removeFirst(4) //remove lenght header for the privkey data blob
		
		guard (dataBlob as NSData).subdata(with: NSRange(0...3)) == (dataBlob as NSData).subdata(with: NSRange(4...7)) else {
			fatalError("checkints are different")
		}
		dataBlob.removeFirst(8) //remove checkints
		removeField(&dataBlob) // remove pubkey type header
		removeField(&dataBlob) // remove pubkey
		
		var privatekeyData = extractField(&dataBlob) //extract privkey
		guard Data((privatekeyData as NSData)[32..<64]) == pubkeyData else {
			fatalError("pubkeys dont match")
		}
		privatekeyData.removeLast(32) //remove pubkey from privkey
		
		let comment = String(data: extractField(&dataBlob), encoding: .utf8)!
		
		return Keypair(type: .ed25519, name: comment, privateKey: privatekeyData)
	}
	
	static func makeSSHPrivkey(_ keypair: Keypair) -> Data {
		var content: Data = Data()
		var blob: Data = Data()
		
		let header = "-----BEGIN OPENSSH PRIVATE KEY-----\n"
		let footer = "\n-----END OPENSSH PRIVATE KEY-----\n"
		
		//add header
		content += header.data(using: .utf8)!
		
		//add the magik prefix
		blob += Data("openssh-key-v1\0".utf8)
		//add encryption info
		blob += encode(str: "none")
		//add kdf info
		blob += encode(str: "none") + encode(data: Data())
		//add key count
		blob += encode(int: 1)

		//add atual key
		var pubkeyBlob = Data()
		let keyType = "ssh-ed25519"
		pubkeyBlob += encode(str: keyType)
		pubkeyBlob += encode(data: keypair.publicKey)
		blob += encode(data: pubkeyBlob)
		
		//priv
		var privBlob = Data()
		let checkint = UInt32.random(in: UInt32.min...UInt32.max)
		privBlob.append(contentsOf: withUnsafeBytes(of: checkint.bigEndian, Array.init))
		privBlob.append(contentsOf: withUnsafeBytes(of: checkint.bigEndian, Array.init))
		privBlob += encode(str: keyType)
		privBlob += encode(data: keypair.publicKey)
		privBlob += encode(data: keypair.privateKey + keypair.publicKey)
		privBlob += encode(str: keypair.name)
		
		let padLegth = (8 - (privBlob.count % 8)) % 8
		if padLegth > 0 {
			privBlob.append(contentsOf: (1...padLegth).map { UInt8($0) } )
		}
		
		blob += encode(data: privBlob)
		
		content += blob.base64EncodedData(options: .lineLength64Characters)
		
		//footer
		content += footer.data(using: .utf8)!
		
		return content
	}
	
	//MARK: openssh conversion helpers
	static func encode(str: String) -> Data {
		guard let utf8 = str.data(using: .utf8) else {
			return Data()
		}
		return encode(int: utf8.count) + utf8
	}
	
	static func encode(data: Data) -> Data {
		return encode(int: data.count) + data
	}
	
	static func encode(int: Int) -> Data {
		var bigEndian = UInt32(int).bigEndian
		return Data(bytes: &bigEndian, count: 4) // 32bits / 8 bitsperbyte
	}
	
	static func removeField(_ data: inout Data) {
		guard data.count >= 4 else { return }
		
		let length = (data as NSData)[3]
		guard data.count >= 4 + Int(length) else { return }
		
		data.removeFirst(4)
		data.removeFirst(Int(length))
	}
	
	static func extractField(_ data: inout Data) -> Data {
		let nsdata = data as NSData
		let lenght = Int(nsdata[3])
		let extracted = Data(nsdata[4..<(lenght+4)])
		data.removeFirst(4 + lenght)
		return extracted
	}
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
