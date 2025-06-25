//
//  SSHState.swift
//  ShhShell
//
//  Created by neon443 on 25/06/2025.
//

import Foundation

enum SSHState {
	case idle
	case connecting
	case authorizing
	case authorized
	case shellOpen
//	case unauthorized
}
