//
//  SSHError.swift
//  ShhShell
//
//  Created by neon443 on 23/06/2025.
//

import Foundation

enum SSHError: Error {
	case connectionFailed(String)
	case communicationError(String)
	case backendError(String)
}

enum AuthError: Error {
	case rejectedCredentials
	case notConnected
}

enum KeyError: Error {
	case importPubkeyError
	case importPrivkeyError
	case pubkeyRejected
	case privkeyRejected
}
