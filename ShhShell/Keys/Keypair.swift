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
	var type: KeyType = .ecdsa
	var name: String = ""
	var publicKey: Data {
		(try? Curve25519.Signing.PrivateKey(rawRepresentation: privateKey).publicKey.rawRepresentation) ?? Data()
	}
	var privateKey: Data
	var passphrase: String = ""
	
	var openSshPubkey: String {
		String(data: KeyManager.makeSSHPubkey(pub: publicKey, comment: name), encoding: .utf8) ?? "OpenSSH key format error"
	}
	
	var openSshPrivkey: String {
		String(data: KeyManager.makeSSHPrivkey(pub: publicKey, priv: privateKey, comment: name), encoding: .utf8) ?? "OpenSSH key format error"
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
