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
	var id = UUID()
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
	
	static func fromiTermColors(name: String, data: Data?) -> Theme? {
		guard let data else { return nil }
		
		let decoder = PropertyListDecoder()
		
		guard let decoded = try? decoder.decode(ThemeCodable.self, from: data) else { return nil }
		
		let theme = Theme(
			name: name,
			ansi: decoded.ansi,
			foreground: Color(decoded.foreground),
			background: Color(decoded.background),
			cursor: Color(decoded.cursor),
			cursorText: Color(decoded.cursorText),
			bold: Color(decoded.bold),
			selectedText: Color(decoded.selectedText),
			selection: Color(decoded.selection)
		)
		return theme
	}
}


struct ThemeCodable: Codable {
	var ansi0: ColorCodable
	var ansi1: ColorCodable
	var ansi2: ColorCodable
	var ansi3: ColorCodable
	var ansi4: ColorCodable
	var ansi5: ColorCodable
	var ansi6: ColorCodable
	var ansi7: ColorCodable
	var ansi8: ColorCodable
	var ansi9: ColorCodable
	var ansi10: ColorCodable
	var ansi11: ColorCodable
	var ansi12: ColorCodable
	var ansi13: ColorCodable
	var ansi14: ColorCodable
	var ansi15: ColorCodable
	var foreground: ColorCodable
	var background: ColorCodable
	var cursor: ColorCodable
	var cursorText: ColorCodable
	var bold: ColorCodable
	var selectedText: ColorCodable
	var selection: ColorCodable
	
	enum CodingKeys: String, CodingKey {
		case ansi0 = "Ansi 0 Color"
		case ansi1 = "Ansi 1 Color"
		case ansi2 = "Ansi 2 Color"
		case ansi3 = "Ansi 3 Color"
		case ansi4 = "Ansi 4 Color"
		case ansi5 = "Ansi 5 Color"
		case ansi6 = "Ansi 6 Color"
		case ansi7 = "Ansi 7 Color"
		case ansi8 = "Ansi 8 Color"
		case ansi9 = "Ansi 9 Color"
		case ansi10 = "Ansi 10 Color"
		case ansi11 = "Ansi 11 Color"
		case ansi12 = "Ansi 12 Color"
		case ansi13 = "Ansi 13 Color"
		case ansi14 = "Ansi 14 Color"
		case ansi15 = "Ansi 15 Color"
		case foreground = "Foreground Color"
		case background = "Background Color"
		case cursor = "Cursor Color"
		case cursorText = "Cursor Text Color"
		case bold = "Bold Color"
		case selectedText = "Selected Text Color"
		case selection = "Selection Color"
	}
}

extension ThemeCodable {
	var ansi: [SwiftTerm.Color] {
		let arr = [ansi0, ansi1, ansi2, ansi3, ansi4, ansi5, ansi6, ansi7, ansi8, ansi9, ansi10, ansi11, ansi12, ansi13, ansi14, ansi15]
		return arr.map(SwiftTerm.Color.init)
	}
}

struct ColorCodable: Codable {
	var red: Double
	var green: Double
	var blue: Double
	
	enum CodingKeys: String, CodingKey {
		case red = "Red Component"
		case green = "Green Component"
		case blue = "Blue Component"
	}
}


extension SwiftTerm.Color {
	convenience init(_ colorCodable: ColorCodable) {
		let red = UInt16(colorCodable.red * 65535)
		let green = UInt16(colorCodable.green * 65535)
		let blue = UInt16(colorCodable.blue * 65535)
		self.init(red: red, green: green, blue: blue)
	}
	
	var colorCodable: ColorCodable {
		let red = Double(self.red)/65535
		let green = Double(self.green)/65535
		let blue = Double(self.blue)/65535
		return ColorCodable(red: red, green: green, blue: blue)
	}
}

extension SwiftTerm.Color {
	var uiColor: UIColor {
		let red = CGFloat(self.red/65535)
		let green = CGFloat(self.green/65535)
		let blue = CGFloat(self.blue/65535)
		return UIColor(red: red, green: green, blue: blue, alpha: 1)
	}
}
