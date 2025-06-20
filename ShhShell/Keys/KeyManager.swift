//
//  KeyManager.swift
//  ShhShell
//
//  Created by neon443 on 20/06/2025.
//

import Foundation

struct Key: Identifiable, Hashable {
	var id = UUID()
	var privateKey: SecKey
	var publicKey: SecKey {
		SecKeyCopyPublicKey(privateKey)!
	}
}

class KeyManager: ObservableObject {
	func generateRSA() throws {
		let type = kSecAttrKeyTypeRSA
		let tag = "com.neon443.ShhSell.keys.\(Date().timeIntervalSince1970)".data(using: .utf8)!
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
		
		print(SecKeyCopyPublicKey(privateKey))
	}
}
