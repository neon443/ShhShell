//
//  Symbol.swift
//  ShhShell
//
//  Created by neon443 on 26/06/2025.
//

import Foundation
import SwiftUI

enum Symbol: Codable, Hashable, Equatable, CaseIterable {
	case desktopcomputer
	case laptopcomputer
	
	case trashcan
	
	case genericPC
	case genericServer
	case genericServerVertical
	
	var sf: String {
		switch self {
		case .desktopcomputer:
			return "desktopcomputer"
		case .laptopcomputer:
			return "laptopcomputer"
			
		case .trashcan:
			return "macpro.gen2"
			
		case .genericPC:
			return "custom.pc"
		case .genericServer:
			return "rectangle"
		case .genericServerVertical:
			return "rectangle.portrait"
		}
		
	}
	
	var isCustom: Bool {
		switch self {
		case .genericPC:
			return true
		default:
			return false
		}
	}
	
	var offset: CGSize {
		var deltaHeight: Double
		switch self {
		case .desktopcomputer:
			deltaHeight = -6
		case .laptopcomputer:
			deltaHeight = -2
		case .genericPC:
			deltaHeight = -6
		default:
			deltaHeight = 0
		}
		return CGSize(width: 0, height: deltaHeight)
	}
}
