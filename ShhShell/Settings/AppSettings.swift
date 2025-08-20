//
//  AppSettings.swift
//  ShhShell
//
//  Created by neon443 on 19/08/2025.
//

import Foundation
import SwiftUI

struct AppSettings: Codable, Sendable {
	var scrollback: CGFloat = 1_000
	var cursorStyle: CursorStyle = .block
	var locationPersist: Bool = false
	var bellSound: Bool = false
	var bellHaptic: Bool = true
	var caffeinate: Bool = false
	var filter: TerminalFilter = .none
	var appIcon: AppIcon = .regular
}

enum CursorStyle: Codable, CaseIterable {
	case block
	case bar
}

enum TerminalFilter: Codable, CaseIterable {
	case none
	case crt
}

enum AppIcon: Codable, CaseIterable {
	case regular
	case blueprint
	
	var image: Image {
		switch self {
		case .regular:
			Image("Icon")
		case .blueprint:
			Image(uiImage: UIImage())
		}
	}
}
