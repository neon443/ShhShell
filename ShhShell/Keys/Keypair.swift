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
			return Data()
		} else {
			return (try? Curve25519.Signing.PrivateKey(rawRepresentation: privateKey).publicKey.rawRepresentation) ?? Data()
		}
	}
	var privateKey: Data
	var passphrase: String = ""
	
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
	
	static func ==(lhs: Keypair, rhs: Keypair) -> Bool {
		if lhs.publicKey.base64EncodedString() == rhs.publicKey.base64EncodedString()
			&& lhs.privateKey.base64EncodedString() == rhs.privateKey.base64EncodedString() {
			return true
		} else {
			return false
		}
	}
}
