//
//  Fonts.swift
//  ShhShell
//
//  Created by neon443 on 06/07/2025.
//

import Foundation

enum FontFamilies: String, CaseIterable, CustomStringConvertible {
	case mesloLGSNF = "MesloLGS NF"
	case sfMono = "SF Mono"
	case cascadiaMono = "Cascadia Mono"
	case jetbrainsMonoNF = "JetBrainsMono Nerd Font Mono"
	
	static var allCasesRaw: [String] {
		return allCases.map { $0.rawValue }
	}
	
	var description: String {
		switch self {
		case .mesloLGSNF:
			"MesloLGS-NF-Regular"
		case .sfMono:
			"SFMono-Regular"
		case .cascadiaMono:
			"CascadiaMono-Regular"
		case .jetbrainsMonoNF:
			"JetBrainsMonoNFM-Regular"
		}
	}
}
