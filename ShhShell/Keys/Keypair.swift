//
//  Keypair.swift
//  ShhShell
//
//  Created by neon443 on 25/06/2025.
//

import Foundation

protocol KeypairProtocol: Identifiable, Equatable, Codable, Hashable {
	var id: UUID { get }
	var type: KeyType { get set }
	var name: String { get set }
	var publicKey: Data? { get set }
	var privateKey: Data? { get set }
	var passphrase: String { get set }
}

struct Keypair: KeypairProtocol {
	var id = UUID()
	var type: KeyType = .rsa(4096)
	var name: String = ""
	var publicKey: Data?
	var privateKey: Data?
	var passphrase: String = ""
	
	init(
		id: UUID = UUID(),
		type: KeyType,
		name: String,
		publicKey: String,
		privateKey: String,
		passphrase: String = ""
	) {
		self.id = id
		self.type = type
		self.name = name
		self.publicKey = publicKey.data(using: .utf8)
		self.privateKey = privateKey.data(using: .utf8)
		self.passphrase = passphrase
	}
	
	static func ==(lhs: Keypair, rhs: Keypair) -> Bool {
		if lhs.publicKey?.base64EncodedString() == rhs.publicKey?.base64EncodedString()
			&& lhs.privateKey?.base64EncodedString() == rhs.privateKey?.base64EncodedString() {
			return true
		} else {
			return false
		}
	}
}
