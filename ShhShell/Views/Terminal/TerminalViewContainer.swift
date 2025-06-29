//
//  TerminalViewContainer.swift
//  ShhShell
//
//  Created by neon443 on 29/06/2025.
//

import Foundation

public final class TerminalViewContainer {
	@MainActor static var shared: [
		UUID: TerminalContainer
	] = [:]
}

struct TerminalContainer {
	var handler: SSHHandler
	var terminalView: SSHTerminalDelegate
}
