//
//  ThemeCodable.swift
//  ShhShell
//
//  Created by neon443 on 29/06/2025.
//

import Foundation
import SwiftTerm

struct ThemeCodable: Codable {
	var id: String?
	var name: String?
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
		case id = "id"
		case name = "name"
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

extension ThemeCodable {
	func toTheme() -> Theme {
		return Theme(
			id: self.id ?? UUID().uuidString,
			name: self.name ?? "",
			ansi: self.ansi,
			foreground: self.foreground.stColor,
			background: self.background.stColor,
			cursor: self.cursor.stColor,
			cursorText: self.cursorText.stColor,
			bold: self.bold.stColor,
			selectedText: self.selectedText.stColor,
			selection: self.selection.stColor
		)
	}
}
