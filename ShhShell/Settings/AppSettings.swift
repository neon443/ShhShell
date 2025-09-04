//
//  AppSettings.swift
//  ShhShell
//
//  Created by neon443 on 19/08/2025.
//

import Foundation
import SwiftUI
@preconcurrency import SwiftTerm

struct AppSettings: Codable, Sendable, Equatable {
	var scrollback: CGFloat = 10_000
	var cursorType: CursorType = CursorType()
	var cursorAnimations: CursorAnimations = CursorAnimations()
	var locationPersist: Bool = false
	var bellSound: Bool = false
	var bellHaptic: Bool = true
	var caffeinate: Bool = false
	var filter: TerminalFilter = .none
	var appIcon: AppIcon = .regular
}

enum CursorShape: Codable, CaseIterable, Equatable, CustomStringConvertible {
	case block
	case bar
	case underline
	
	var description: String {
		switch self {
		case .block:
			return "Block"
		case .bar:
			return "Bar"
		case .underline:
			return "Underline"
		}
	}
}

struct CursorType: Codable, Equatable, CustomStringConvertible {
	var cursorShape: CursorShape = .block
	var blink: Bool = true
	
	var stCursorStyle: SwiftTerm.CursorStyle {
		switch cursorShape {
		case .block:
			return blink ? .blinkBlock : .steadyBlock
		case .bar:
			return blink ? .blinkBar : .steadyBar
		case .underline:
			return blink ? .blinkUnderline : .steadyUnderline
		}
	}
	
	var description: String {
		return (blink ? "Blinking" : "Steady") + " " + cursorShape.description
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
			return "Blueprint"
		}
	}
}
