//
//  AuthType.swift
//  ShhShell
//
//  Created by neon443 on 03/07/2025.
//

import Foundation

enum AuthType: UInt32, CustomStringConvertible, CaseIterable {
	case password = 2
	case publickey = 4
	case hostbased = 8
	case interactive = 16
	var description: String {
		switch self {
		case .password:
			return "Password"
		case .publickey:
			return "Publickey"
		case .hostbased:
			return "Hostbased"
		case .interactive:
			return "Keyboard Interactive"
		}
	}
}
