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
		let key = Curve25519.Signing.PrivateKey()
		let privatekeyData = key.rawRepresentation
		let publickeyData = key.publicKey.rawRepresentation
		print(publickeyData.base64EncodedString())
		let pubpem = makeSSHPubkey(pub: publickeyData, comment: "neon443@m")
		let privpem = makeSSHPrivkey(pub: publickeyData, priv: privatekeyData, comment: "neon443@m")
		print(String(data: pubpem, encoding: .utf8)!)
		print()
		print(String(data: privpem, encoding: .utf8)!)
		print()
		
		print(importSSHPubkey(pub: String(data: pubpem, encoding: .utf8)!).base64EncodedString())
		
		print(privatekeyData.base64EncodedString())
		print(importSSHPrivkey(priv: String(data: privpem, encoding: .utf8)!).base64EncodedString())
		fatalError()
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
			fatalError("unimplemented")
		case .rsa(let rsaSize):
			fatalError("unimplemented")
		}
	}
	
	func importSSHPubkey(pub: String) -> Data {
		let split = pub.split(separator: " ")
		guard split.count == 3 else { return Data() }
		
		var pubdata = Data(base64Encoded: String(split[1]))!
		while pubdata.count != 36 {
			removeField(&pubdata)
		}
		pubdata.removeFirst(4)
		return pubdata
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
	
	func importSSHPrivkey(priv: String) -> Data {
		var split = priv.replacingOccurrences(of: "-----BEGIN OPENSSH PRIVATE KEY-----\n", with: "")
		split = split.replacingOccurrences(of: "-----BEGIN OPENSSH PRIVATE KEY-----", with: "")
		split = split.replacingOccurrences(of: "\n-----END OPENSSH PRIVATE KEY-----\n", with: "")
		split = split.replacingOccurrences(of: "\n-----END OPENSSH PRIVATE KEY-----", with: "")
		split = split.replacingOccurrences(of: "-----END OPENSSH PRIVATE KEY-----", with: "")
		split = split.replacingOccurrences(of: "\r\n", with: "")
		split = split.replacingOccurrences(of: "\n", with: "")

		var dataBlob = Data(base64Encoded: split.data(using: .utf8)!)!
		dataBlob.removeFirst(15) //remove magik header
		
		for _ in 0..<2 {
			removeField(&dataBlob)
		} //remove the 2 nones fro encryption and kdf
		removeField(&dataBlob) //remove the empty Data()
		

		return Data()
	}
	
	func makeSSHPrivkey(pub: Data, priv: Data, comment: String) -> Data {
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
		pubkeyBlob += encode(data: pub)
		blob += encode(data: pubkeyBlob)
		
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
		var bigEndian = UInt32(int).bigEndian
		return Data(bytes: &bigEndian, count: 4) // 32bits / 8 bitsperbyte
	}
	
	func removeField(_ data: inout Data) {
		guard data.count >= 4 else { return }
		
		let lengthBytes = data.subdata(in: 0..<4)
		let length = lengthBytes.withUnsafeBytes { $0.load(as: UInt32.self).bigEndian }
		guard data.count >= 4 + Int(length) else { return }
		
		data.removeFirst(4)
		data.removeFirst(Int(length))
	}
}
