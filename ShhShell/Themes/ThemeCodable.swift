//
//  ThemeCodable.swift
//  ShhShell
//
//  Created by neon443 on 29/06/2025.
//

import Foundation
import SwiftTerm
import SwiftUI

struct ThemeCodable: Codable, Hashable, Equatable {
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

extension ThemeCodable {
	subscript(ansiIndex index: Int) -> SwiftUI.Color {
		get {
			switch index {
			case 0: return ansi0.stColor.suiColor
			case 1: return ansi1.stColor.suiColor
			case 2: return ansi2.stColor.suiColor
			case 3: return ansi3.stColor.suiColor
			case 4: return ansi4.stColor.suiColor
			case 5: return ansi5.stColor.suiColor
			case 6: return ansi6.stColor.suiColor
			case 7: return ansi7.stColor.suiColor
			case 8: return ansi8.stColor.suiColor
			case 9: return ansi9.stColor.suiColor
			case 10: return ansi10.stColor.suiColor
			case 11: return ansi11.stColor.suiColor
			case 12: return ansi12.stColor.suiColor
			case 13: return ansi13.stColor.suiColor
			case 14: return ansi14.stColor.suiColor
			case 15: return ansi15.stColor.suiColor
			default: fatalError()
			}
		}
		set {
			let cc = ColorCodable(color: newValue)
			switch index {
			case 0:
				ansi0.red = cc.red
				ansi0.green = cc.green
				ansi0.blue = cc.blue
			case 1:
				ansi1.red = cc.red
				ansi1.green = cc.green
				ansi1.blue = cc.blue
			case 2:
				ansi2.red = cc.red
				ansi2.green = cc.green
				ansi2.blue = cc.blue
			case 3:
				ansi3.red = cc.red
				ansi3.green = cc.green
				ansi3.blue = cc.blue
			case 4:
				ansi4.red = cc.red
				ansi4.green = cc.green
				ansi4.blue = cc.blue
			case 5:
				ansi5.red = cc.red
				ansi5.green = cc.green
				ansi5.blue = cc.blue
			case 6:
				ansi6.red = cc.red
				ansi6.green = cc.green
				ansi6.blue = cc.blue
			case 7:
				ansi7.red = cc.red
				ansi7.green = cc.green
				ansi7.blue = cc.blue
			case 8:
				ansi8.red = cc.red
				ansi8.green = cc.green
				ansi8.blue = cc.blue
			case 9:
				ansi9.red = cc.red
				ansi9.green = cc.green
				ansi9.blue = cc.blue
			case 10:
				ansi10.red = cc.red
				ansi10.green = cc.green
				ansi10.blue = cc.blue
			case 11:
				ansi11.red = cc.red
				ansi11.green = cc.green
				ansi11.blue = cc.blue
			case 12:
				ansi12.red = cc.red
				ansi12.green = cc.green
				ansi12.blue = cc.blue
			case 13:
				ansi13.red = cc.red
				ansi13.green = cc.green
				ansi13.blue = cc.blue
			case 14:
				ansi14.red = cc.red
				ansi14.green = cc.green
				ansi14.blue = cc.blue
			case 15:
				ansi15.red = cc.red
				ansi15.green = cc.green
				ansi15.blue = cc.blue
			default: fatalError()
			}
		}
	}
}
