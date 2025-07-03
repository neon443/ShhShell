//
//  Keypair.swift
//  ShhShell
//
//  Created by neon443 on 25/06/2025.
//

import Foundation
import CryptoKit

protocol KeypairProtocol: Identifiable, Equatable, Codable, Hashable {
	var id: UUID { get }
	var type: KeyType { get set }
	var name: String { get set }
	var publicKey: Data { get }
	var privateKey: Data { get set }
	var passphrase: String { get set }
	
	var openSshPubkey: String { get }
	var openSshPrivkey: String { get }
}

struct Keypair: KeypairProtocol {
	var id = UUID()
	var type: KeyType = .ed25519
	var name: String = ""
	var publicKey: Data {
		if privateKey.isEmpty {
			print("not a valid ed25519 key")
			fatalError()
		} else {
			return (try? Curve25519.Signing.PrivateKey(rawRepresentation: privateKey).publicKey.rawRepresentation) ?? Data()
		}
	}
	var privateKey: Data
	var passphrase: String = ""
	
	enum CodingKeys: String, CodingKey {
		case id = "id"
		case type = "type"
		case name = "name"
		
//		case privateKey = "privateKey"
//		case passphrase = "passphrase"
	}
	
	var label: String {
		if name.isEmpty {
			return openSshPubkey
		} else {
			return name
		}
	}
	
	var base64Pubkey: String {
		String(openSshPubkey.split(separator: " ")[1])
	}
	
	var base64Privkey: String {
		var opensshprivkey = openSshPrivkey
		let header = "-----BEGIN OPENSSH PRIVATE KEY-----\n"
		let footer = "\n-----END OPENSSH PRIVATE KEY-----\n"
		opensshprivkey = opensshprivkey.replacingOccurrences(of: header, with: "")
		opensshprivkey = opensshprivkey.replacingOccurrences(of: footer, with: "")
		return opensshprivkey
	}
	
	var openSshPubkey: String {
		if privateKey.isEmpty {
			return ""
		} else {
			return String(data: KeyManager.makeSSHPubkey(self), encoding: .utf8) ?? "OpenSSH key format error"
		}
			
	}
	
	var openSshPrivkey: String {
		String(data: KeyManager.makeSSHPrivkey(self), encoding: .utf8) ?? "OpenSSH key format error"
	}
	
	init(
		id: UUID = UUID(),
		type: KeyType,
		name: String,
		privateKey: Data,
		passphrase: String = ""
	) {
		self.id = id
		self.type = type
		self.name = name
		self.privateKey = privateKey
		self.passphrase = passphrase
	}
	
	init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.id = try container.decode(UUID.self, forKey: .id)
		self.type = try container.decode(KeyType.self, forKey: .type)
		self.name = try container.decode(String.self, forKey: .name)
//		self.privateKey = try container.decode(Data.self, forKey: .privateKey)
//		self.passphrase = try container.decode(String.self, forKey: .passphrase)
		self.privateKey = Data()
		self.passphrase = ""
	}
	
	static func ==(lhs: Keypair, rhs: Keypair) -> Bool {
		if lhs.publicKey.base64EncodedString() == rhs.publicKey.base64EncodedString()
			&& lhs.privateKey.base64EncodedString() == rhs.privateKey.base64EncodedString() {
			return true
		} else {
			return false
		}
	}
}
