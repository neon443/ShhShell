//
//  AppSettings.swift
//  ShhShell
//
//  Created by neon443 on 19/08/2025.
//

import Foundation
import SwiftUI

struct AppSettings: Codable, Sendable, Equatable {
	var scrollback: CGFloat = 10_000
	var cursorStyle: CursorStyle = .block
	var locationPersist: Bool = false
	var bellSound: Bool = false
	var bellHaptic: Bool = true
	var caffeinate: Bool = false
	var filter: TerminalFilter = .none
	var appIcon: AppIcon = .regular
}

enum CursorStyle: Codable, CaseIterable, Equatable, CustomStringConvertible {
	case block
	case bar
	
	var description: String {
		switch self {
		case .block:
			return "Block"
		case .bar:
			return "Bar"
		}
	}
}

enum TerminalFilter: Codable, CaseIterable, Equatable, CustomStringConvertible {
	case none
	case crt
	
	var description: String {
		switch self {
		case .none:
			return "None"
		case .crt:
			return "CRT"
		}
	}
}

enum AppIcon: Codable, CaseIterable, Equatable, CustomStringConvertible {
	case regular
	case beta
	case betaBlueprint
	
	var image: Image {
		return Image(self.name)
	}
	
	var name: String {
		switch self {
		case .regular:
			return "regular"
		case .beta:
			return "beta"
		case .betaBlueprint:
			return "betaBlueprint"
		}
	}
	
	var description: String {
		switch self {
		case .regular:
			return "Default"
		case .beta:
			return "Beta"
		case .betaBlueprint:
			return "Beta Blueprint"
		}
	}
}
