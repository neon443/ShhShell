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
	
	init() {
		let key = try! Curve25519.Signing.PrivateKey(rawRepresentation: generateEd25519())
		let pubpem = makeSSHPubkey(pub: key.publicKey.rawRepresentation, comment: "ShhShell Test!")
		let privpem = makeSSHPrivkey(pub: key.publicKey.rawRepresentation, priv: key.rawRepresentation, comment: "ShhShell Test!")
		print(String(data: pubpem, encoding: .utf8)!)
		print()
		print(String(data: privpem, encoding: .utf8)!)
		print()
	}
	
	func loadTags() {
		userdefaults.synchronize()
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
	func generateKey(type: KeyType, SEPKeyTag: String, comment: String, passphrase: String) -> Keypair? {
		switch type {
		case .ecdsa(let inSEP):
			generateEd25519()
			return nil
		case .rsa(let rsaSize):
			guard let keyData = try? generateRSA(size: rsaSize) else { return nil }
			fatalError()
//			return Keypair(
//				type: .rsa(rsaSize),
//				name: comment,
//				publicKey: keyData.base64EncodedString(),
//				privateKey: keyData.priv.base64EncodedString(),
//				passphrase: ""
//			)
		}
	}
	
	func generateEd25519() -> Data {
		return Curve25519.Signing.PrivateKey().rawRepresentation
	}
	
	func generateRSA(size: Int) throws -> SecKey {
		let header = "ssh-ed25519 "
		let type = kSecAttrKeyTypeRSA
		let tag = Date().ISO8601Format().data(using: .utf8)!
		let attributes: [String: Any] =
		[kSecAttrKeyType as String:			type,
		 kSecAttrKeySizeInBits as String:	size,
		 kSecPrivateKeyAttrs as String:
			[kSecAttrIsPermanent as String: 	true,
			kSecAttrApplicationTag as String: 	tag]
		]
		
		var error: Unmanaged<CFError>?
		guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
			throw error!.takeRetainedValue() as Error
		}
		
		return privateKey
	}
	
	func makeSSHPubkey(pub: Data, comment: String) -> Data {
		let header = "ssh-ed25519"
		var keyBlob: Data = Data()
		//key type bit
		keyBlob += encode(str: header)
		//base64 blob bit
		keyBlob += encode(data: pub)
		
		let b64key = keyBlob.base64EncodedString()
		let pubkeyline = "\(header) \(b64key) \(comment)\n"
		return Data(pubkeyline.utf8)
	}
	
	func makeSSHPrivkey(pub: Data, priv: Data, comment: String) -> Data {
		var content: Data = Data()
		var blob: Data = Data()
		
		let header = "-----BEGIN OPENSSH PRIVATE KEY-----\n"
		let footer = "\n-----END OPENSSH PRIVATE KEY-----\n"
		
		//add header
		content += header.data(using: .utf8)!
		
		//add the magik prefix
		blob += encode(str: "openssh-key-v1\0")
		//add encryption info
		blob += encode(str: "none")
		//add kdf info
		blob += encode(str: "none") + encode(data: Data())
		//add key count
		blob += encode(int: 1)
		//add atual key
		let keyType = "ssh-ed25519"
		blob += encode(str: keyType)
		blob += encode(data: pub)
		
		//priv
		var privBlob = Data()
		let checkint = UInt32.random(in: UInt32.min...UInt32.max)
		privBlob.append(contentsOf: withUnsafeBytes(of: checkint.bigEndian, Array.init))
		privBlob.append(contentsOf: withUnsafeBytes(of: checkint.bigEndian, Array.init))
		privBlob += encode(str: keyType)
		privBlob += encode(data: pub)
		privBlob += encode(data: priv + pub)
		privBlob += encode(str: comment)
		
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
	
	func encode(str: String) -> Data {
		guard let utf8 = str.data(using: .utf8) else {
			return Data()
		}
		return encode(int: utf8.count) + utf8
	}
	
	func encode(data: Data) -> Data {
		return encode(int: data.count) + data
	}
	
	func encode(int: Int) -> Data {
		var bigEndian = Int32(int).bigEndian
		return Data(bytes: &bigEndian, count: 4) // 32bits / 8 bitsperbyte
	}
}
