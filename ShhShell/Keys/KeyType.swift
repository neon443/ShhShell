//
//  KeyType.swift
//  ShhShell
//
//  Created by neon443 on 30/06/2025.
//

import Foundation

enum KeyType: Codable, Equatable, Hashable, CustomStringConvertible, CaseIterable {
	case ed25519
	
	var description: String {
		switch self {
		case .ed25519:
			return "Ed25519"
		}
	}
}
