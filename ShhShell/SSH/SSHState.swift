//
//  SSHState.swift
//  ShhShell
//
//  Created by neon443 on 25/06/2025.
//

import Foundation
import SwiftUI

enum SSHState {
	case idle
	case connecting
	case authorizing
	case authorized
	case shellOpen
	
	case connectionFailed
	case authFailed
	
	var color: Color {
		switch self {
		case .idle:
			return .gray
			
		case .connecting, .authorizing:
			return .orange
			
		case .authorized, .shellOpen:
			return .green
			
		case .connectionFailed, .authFailed:
			return .red
		}
	}
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
