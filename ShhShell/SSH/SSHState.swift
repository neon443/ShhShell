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
}

func checkConnected(_ state: SSHState) -> Bool {
	return !(state == .idle || state == .connecting)
}

func checkAuth(_ state: SSHState) -> Bool {
	return state == .authorized || state == .shellOpen
}

func checkShell(_ state: SSHState) -> Bool {
	return state == .shellOpen
}
