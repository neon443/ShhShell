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
		case .ecdsa:
			return "ECDSA"
		case .rsa:
			return "RSA"
		}
	}
	
	case ecdsa
	case rsa
}
