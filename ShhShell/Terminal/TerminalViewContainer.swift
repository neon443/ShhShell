//
//  TerminalViewContainer.swift
//  ShhShell
//
//  Created by neon443 on 29/06/2025.
//

import Foundation

@MainActor
public final class TerminalViewContainer: ObservableObject {
	static let shared = TerminalViewContainer()
	
	@Published var sessions: [UUID: TerminalContainer] = [:]
	
	var sessionIDs: [UUID] {
		return sessions.map({ $0.key })
	}
}

struct TerminalContainer {
	var handler: SSHHandler
	var terminalView: SSHTerminalDelegate
}
