//
//  Keypair.swift
//  ShhShell
//
//  Created by neon443 on 25/06/2025.
//

import Foundation

protocol KeypairProtocol: Identifiable, Equatable, Codable, Hashable {
	var publicKey: Data? { get set }
	var privateKey: Data? { get set }
}

struct Keypair: KeypairProtocol {
	var id = UUID()
	var publicKey: Data?
	var privateKey: Data?
	
	init(
		publicKey: Data?,
		privateKey: Data?
	) {
		self.publicKey = publicKey
		self.privateKey = privateKey
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
