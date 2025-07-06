//
//  Fonts.swift
//  ShhShell
//
//  Created by neon443 on 06/07/2025.
//

import Foundation

enum Fonts: String, CaseIterable/*, CustomStringConvertible*/ {
	case mesloLGSNF = "MesloLGS-NF-Regular"
	case sfMono = "SFMono-Regular"
	case cascadiaMono = "CascadiaMono-Regular"
	case geistMonoNF = "GeistMonoNFM-Regular"
	case jetbrainsMonoNF = "JetBrainsMonoNFM-Regular"
	case comicSans = "ComicSansMS"
	case comicMono = "ComicMono"
	
	static var fontNames: [String] {
		return Fonts.allCases.map { $0.rawValue }
	}
}
