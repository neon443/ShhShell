//
//  KeyManager.swift
//  ShhShell
//
//  Created by neon443 on 20/06/2025.
//

import Foundation
import CryptoKit
import Security

struct Key: Identifiable, Hashable {
	var id = UUID()
	var privateKey: SecKey
	var publicKey: SecKey {
		SecKeyCopyPublicKey(privateKey)!
	}
}

class KeyManager: ObservableObject {
	private let userdefaults = NSUbiquitousKeyValueStore.default
	
	var tags: [String] = []
	
	func loadTags() {
		let decoder = JSONDecoder()
		guard let data = userdefaults.data(forKey: "keyTags") else { return }
		guard let decoded = try? decoder.decode([String].self, from: data) else { return }
		tags = decoded
	}
	
	func saveTags() {
		let encoder = JSONEncoder()
		guard let encoded = try? encoder.encode(tags) else { return }
		userdefaults.set(encoded, forKey: "keyTags")
		userdefaults.synchronize()
	}
	
	//MARK: generate keys
	func generateEd25519() {
		let privateKey = Curve25519.Signing.PrivateKey()
		let publicKeyData = privateKey.publicKey
		dump(privateKey.rawRepresentation)
		print(publicKeyData.rawRepresentation)
	}
	
	func generateRSA() throws {
		let type = kSecAttrKeyTypeRSA
		let label = Date().ISO8601Format()
		let tag = label.data(using: .utf8)!
		let attributes: [String: Any] =
		[kSecAttrKeyType as String:			type,
		 kSecAttrKeySizeInBits as String:	4096,
		 kSecPrivateKeyAttrs as String:
			[kSecAttrIsPermanent as String: 	true,
			kSecAttrApplicationTag as String: 	tag]
		]
		
		var error: Unmanaged<CFError>?
		guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
			throw error!.takeRetainedValue() as Error
		}
		print(privateKey)
		
		print(SecKeyCopyPublicKey(privateKey) ?? "")
		print(SecKeyCopyExternalRepresentation(privateKey, nil) as Any)
//		do {
//			try storeKey(privateKey, label: label)
//		} catch {
		//			print(error.localizedDescription)
		//		}
	}
	
	func getPubkey(_ privateKey: SecKey) -> SecKey? {
		return SecKeyCopyPublicKey(privateKey)
	}
}
