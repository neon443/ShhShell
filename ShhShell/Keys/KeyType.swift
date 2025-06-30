//
//  KeyType.swift
//  ShhShell
//
//  Created by neon443 on 30/06/2025.
//

import Foundation

enum KeyType: Codable, Equatable, Hashable, CustomStringConvertible {
	var description: String {
		switch self {
		case .ecdsa(let inSEP):
			return inSEP ? "ECDSA Secure Enclave" : "ECDSA"
		case .rsa(let bits):
			return "RSA \(bits)"
		}
	}
	
	case ecdsa(inSEP: Bool)
	case rsa(Int)
}
