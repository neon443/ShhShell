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

struct Key: Identifiable, Hashable {
	var id = UUID()
	var privateKey: SecKey
	var publicKey: SecKey {
		SecKeyCopyPublicKey(privateKey)!
	}
}

class KeyManager: ObservableObject {
	private let userdefaults = NSUbiquitousKeyValueStore.default
	
	@Published var keypairs: [Keypair] = []
	
	var keyTypes: [UUID: KeyType] = [:]
	var keyNames: [UUID: String] = [:]
	private let baseTag = "com.neon443.ShhShell.keys".data(using: .utf8)!
	
	init() {
		loadKeyIDs()
		for id in keyTypes.keys {
			guard let keypair = getFromKeychain(keyID: id) else { continue }
			keypairs.append(keypair)
		}
	}
	
	func loadKeyIDs() {
		userdefaults.synchronize()
		let decoder = JSONDecoder()
		guard let data = userdefaults.data(forKey: "keyIDs") else { return }
		guard let decoded = try? decoder.decode([UUID:KeyType].self, from: data) else { return }
		keyTypes = decoded
		
		guard let dataNames = userdefaults.data(forKey: "keyNames") else { return }
		guard let decodedNames = try? decoder.decode([UUID:String].self, from: dataNames) else { return }
		keyNames = decodedNames
	}
	
	func saveKeyIDs() {
		let encoder = JSONEncoder()
		guard let encoded = try? encoder.encode(keyTypes) else { return }
		userdefaults.set(encoded, forKey: "keyIDs")

		guard let encodedNames = try? encoder.encode(keyNames) else { return }
		userdefaults.set(encodedNames, forKey: "keyNames")
		userdefaults.synchronize()
	}
	
	func saveToKeychain(_ keypair: Keypair) {
		withAnimation {
			keyTypes.updateValue(keypair.type, forKey: keypair.id)
			keyNames.updateValue(keypair.name, forKey: keypair.id)
		}
		saveKeyIDs()
		if keypair.type == .ed25519 {
			let curve25519 = try! Curve25519.Signing.PrivateKey(rawRepresentation: keypair.privateKey)
			try! GenericPasswordStore().storeKey(curve25519.genericKeyRepresentation, account: keypair.id.uuidString)
		} else {
			let tag = baseTag+keypair.id.uuidString.data(using: .utf8)!
			let addQuery: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
										   kSecAttrApplicationTag as String: tag,
										   kSecValueRef as String: keypair.privateKey,
										   kSecAttrSynchronizable as String: kCFBooleanTrue!]
			let status = SecItemAdd(addQuery as CFDictionary, nil)
			guard status == errSecSuccess else { fatalError() }
		}
	}
	
	func getFromKeychain(keyID: UUID) -> Keypair? {
		guard let keyType = keyTypes[keyID] else { return nil }
		guard let keyName = keyNames[keyID] else { return nil }
		if keyType == .ed25519 {
			var key: Curve25519.Signing.PrivateKey?
			key = try? GenericPasswordStore().readKey(account: keyID.uuidString)
			guard let key else { return nil }
			return Keypair(type: keyType, name: keyName, privateKey: key.rawRepresentation)
		} else {
			let tag = baseTag+keyID.uuidString.data(using: .utf8)!
			let getQuery: [String: Any] = [kSecClass as String: kSecClassKey,
										   kSecAttrApplicationTag as String: tag,
										   kSecAttrKeyType as String: kSecAttrKeyTypeEC,
										   kSecReturnRef as String: true]
			var item: CFTypeRef?
			let status = SecItemCopyMatching(getQuery as CFDictionary, &item)
			guard status == errSecSuccess else { fatalError() }
			return Keypair(
				type: keyType,
				name: keyName,
				privateKey: item as! Data
			)
		}
	}
	
	func importKey(type: KeyType, priv: String, name: String) {
		if type == .ed25519 {
			saveToKeychain(KeyManager.importSSHPrivkey(priv: priv))
		} else { fatalError() }
	}
	
	//MARK: generate keys
	func generateKey(type: KeyType, comment: String) {
		switch type {
		case .ed25519:
			let keypair = Keypair(
				type: .ed25519,
				name: comment,
				privateKey: Curve25519.Signing.PrivateKey().rawRepresentation
			)
			saveToKeychain(keypair)
		case .rsa:
			fatalError("unimplemented")
		}
	}
	
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
		let header = "ssh-ed25519"
		var keyBlob: Data = Data()
		//key type bit
		keyBlob += encode(str: header)
		//base64 blob bit
		keyBlob += encode(data: keypair.publicKey)
		
		let b64key = keyBlob.base64EncodedString()
		let pubkeyline = "\(header) \(b64key) \(keypair.name)\n"
		return Data(pubkeyline.utf8)
	}
	
	static func importSSHPrivkey(priv: String) -> Keypair {
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
	
	func getPubkey(_ privateKey: SecKey) -> SecKey? {
		return SecKeyCopyPublicKey(privateKey)
	}
	
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
