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

//extension ThemeCodable {
//	subscript(ansiIndex index: Int) -> SwiftUI.Color {
//		get {
//			switch index {
//			case 0: return ansi0.stColor.suiColor
//			case 1: return ansi1.stColor.suiColor
//			case 2: return ansi2.stColor.suiColor
//			case 3: return ansi3.stColor.suiColor
//			case 4: return ansi4.stColor.suiColor
//			case 5: return ansi5.stColor.suiColor
//			case 6: return ansi6.stColor.suiColor
//			case 7: return ansi7.stColor.suiColor
//			case 8: return ansi8.stColor.suiColor
//			case 9: return ansi9.stColor.suiColor
//			case 10: return ansi10.stColor.suiColor
//			case 11: return ansi11.stColor.suiColor
//			case 12: return ansi12.stColor.suiColor
//			case 13: return ansi13.stColor.suiColor
//			case 14: return ansi14.stColor.suiColor
//			case 15: return ansi15.stColor.suiColor
//			default: fatalError()
//			}
//		}
//		set {
//			let cc = ColorCodable(color: newValue)
//			switch index {
//			case 0:
//				ansi0.red = cc.red
//				ansi0.green = cc.green
//				ansi0.blue = cc.blue
//			case 1:
//				ansi1.red = cc.red
//				ansi1.green = cc.green
//				ansi1.blue = cc.blue
//			case 2:
//				ansi2.red = cc.red
//				ansi2.green = cc.green
//				ansi2.blue = cc.blue
//			case 3:
//				ansi3.red = cc.red
//				ansi3.green = cc.green
//				ansi3.blue = cc.blue
//			case 4:
//				ansi4.red = cc.red
//				ansi4.green = cc.green
//				ansi4.blue = cc.blue
//			case 5:
//				ansi5.red = cc.red
//				ansi5.green = cc.green
//				ansi5.blue = cc.blue
//			case 6:
//				ansi6.red = cc.red
//				ansi6.green = cc.green
//				ansi6.blue = cc.blue
//			case 7:
//				ansi7.red = cc.red
//				ansi7.green = cc.green
//				ansi7.blue = cc.blue
//			case 8:
//				ansi8.red = cc.red
//				ansi8.green = cc.green
//				ansi8.blue = cc.blue
//			case 9:
//				ansi9.red = cc.red
//				ansi9.green = cc.green
//				ansi9.blue = cc.blue
//			case 10:
//				ansi10.red = cc.red
//				ansi10.green = cc.green
//				ansi10.blue = cc.blue
//			case 11:
//				ansi11.red = cc.red
//				ansi11.green = cc.green
//				ansi11.blue = cc.blue
//			case 12:
//				ansi12.red = cc.red
//				ansi12.green = cc.green
//				ansi12.blue = cc.blue
//			case 13:
//				ansi13.red = cc.red
//				ansi13.green = cc.green
//				ansi13.blue = cc.blue
//			case 14:
//				ansi14.red = cc.red
//				ansi14.green = cc.green
//				ansi14.blue = cc.blue
//			case 15:
//				ansi15.red = cc.red
//				ansi15.green = cc.green
//				ansi15.blue = cc.blue
//			default: fatalError()
//			}
//		}
//	}
//}
