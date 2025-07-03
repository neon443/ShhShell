//
//  ColorCodable.swift
//  ShhShell
//
//  Created by neon443 on 29/06/2025.
//

import Foundation
import SwiftTerm
import SwiftUI

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

extension ColorCodable {
	var stColor: SwiftTerm.Color {
		return SwiftTerm.Color(self)
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
	var suiColor: SwiftUI.Color {
		return Color(uiColor: self.uiColor)
	}
	
	var uiColor: UIColor {
		let red = CGFloat(self.red)/65535
		let green = CGFloat(self.green)/65535
		let blue = CGFloat(self.blue)/65535
		return UIColor(red: red, green: green, blue: blue, alpha: 1)
	}
}

extension SwiftTerm.Color {
	var luminance: Double {
		let r = Double(red)/65535
		let g = Double(green)/65535
		let b = Double(blue)/65535
		return (0.2126*r + 0.7152*g + 0.0722*b)
	}
}
