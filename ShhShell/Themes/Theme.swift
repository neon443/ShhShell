//
//  Theme.swift
//  ShhShell
//
//  Created by neon443 on 27/06/2025.
//

import Foundation
import SwiftTerm
import SwiftUI

struct Theme: Hashable, Equatable, Identifiable {
	var id: String
	var name: String
	var ansi: [SwiftTerm.Color]
	var foreground: SwiftTerm.Color
	var background: SwiftTerm.Color
	var cursor: SwiftTerm.Color
	var cursorText: SwiftTerm.Color
	var bold: SwiftTerm.Color
	var selectedText: SwiftTerm.Color
	var selection: SwiftTerm.Color
	
	var themeCodable: ThemeCodable {
		return ThemeCodable(
			id: id,
			name: name,
			ansi0: ansi[0].colorCodable,
			ansi1: ansi[1].colorCodable,
			ansi2: ansi[2].colorCodable,
			ansi3: ansi[3].colorCodable,
			ansi4: ansi[4].colorCodable,
			ansi5: ansi[5].colorCodable,
			ansi6: ansi[6].colorCodable,
			ansi7: ansi[7].colorCodable,
			ansi8: ansi[8].colorCodable,
			ansi9: ansi[9].colorCodable,
			ansi10: ansi[10].colorCodable,
			ansi11: ansi[11].colorCodable,
			ansi12: ansi[12].colorCodable,
			ansi13: ansi[13].colorCodable,
			ansi14: ansi[14].colorCodable,
			ansi15: ansi[15].colorCodable,
			foreground: foreground.colorCodable,
			background: background.colorCodable,
			cursor: cursor.colorCodable,
			cursorText: cursorText.colorCodable,
			bold: bold.colorCodable,
			selectedText: selectedText.colorCodable,
			selection: selection.colorCodable
		)
	}
	
	static func decodeTheme( data: Data?) -> Theme? {
		guard let data else { fatalError() }
		
		let plistDecoder = PropertyListDecoder()
		let jsonDecoder = JSONDecoder()
		
		guard let decoded =
				(try? plistDecoder.decode(ThemeCodable.self, from: data)) ??
				(try? jsonDecoder.decode(ThemeCodable.self, from: data))
		else { fatalError() }
		return decoded.toTheme()
	}
	
	static func decodeLocalTheme(fileName: String) -> Theme? {
		guard let path = Bundle.main.url(forResource: fileName, withExtension: "plist") else { return nil }
		guard let fileContents = try? Data(contentsOf: path) else { return nil }
		return Theme.decodeTheme(data: fileContents)
	}
	
	static var defaultTheme: Theme {
		return decodeLocalTheme(fileName: "defaultTheme")!
	}
	
	static var builtinThemes: [Theme] {
		return ThemesBuiltin.allCases.map({ decodeLocalTheme(fileName: $0.rawValue)! })
	}
	
	static var newTheme: Theme {
		var result = defaultTheme
		result.id = UUID().uuidString
		return result
	}
}

enum ThemesBuiltin: String, CaseIterable, Hashable, Equatable {
	case defaultTheme = "defaultTheme"
	case xcodeDark = "xcodeDark"
	case xcodeDarkHC = "xcodeDarkHC"
	case xcodeWWDC = "xcodeWWDC"
	case tomorrowNight = "tomorrowNight"
	case zeroXNineSixF = "0x96f"
	case iTerm2SolarizedDark = "iTerm2SolarizedDark"
	case iTerm2SolarizedLight = "iTerm2SolarizedLight"
	case catppuccinFrappe = "catppuccinFrappe"
	case catppuccinMocha = "catppuccinMocha"
	case dracula = "dracula"
	case gruvboxDark = "gruvboxDark"
	case ubuntu = "ubuntu"
}
