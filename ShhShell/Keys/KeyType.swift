//
//  KeyType.swift
//  ShhShell
//
//  Created by neon443 on 30/06/2025.
//

import Foundation

enum KeyType: Codable, Equatable, Hashable, CustomStringConvertible {
	case ed25519
	case rsa
	
	var description: String {
		switch self {
		case .ed25519:
			return "Ed25519"
		case .rsa:
			return "RSA"
		}
	}
}
