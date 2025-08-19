//
//  AppSettings.swift
//  ShhShell
//
//  Created by neon443 on 19/08/2025.
//

import Foundation

struct AppSettings: Codable, Sendable {
	var scrollback: Int = 1_000
	var cursorStyle: CursorStyle = .block
	var locationPersist: Bool = false
	var bellSound: Bool = false
	var bellHaptic: Bool = true
	var caffeinate: Bool = false
	var filter: TerminalFilter = .none
	var appIcon: AppIcon = .regular
}

enum CursorStyle: Codable {
	case block
	case bar
}

enum TerminalFilter: Codable {
	case none
	case crt
}

enum AppIcon: Codable {
	case regular
	case blueprint
}
