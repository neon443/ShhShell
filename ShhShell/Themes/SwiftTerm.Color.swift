//
//  SwiftTerm.Color.swift
//  ShhShell
//
//  Created by neon443 on 08/07/2025.
//

import Foundation
import SwiftUI
import SwiftTerm

extension SwiftTerm.Color {
	var suiColor: SwiftUI.Color {
		get {
			return Color(uiColor: self.uiColor)
		} set {
			let newOne = SwiftTerm.Color(newValue)
			self.red = newOne.red
			self.green = newOne.green
			self.blue = newOne.blue
//			let uiColor = UIColor(newValue)
//			var r: CGFloat = 0; var g: CGFloat = 0; var b: CGFloat = 0
//			uiColor.getRed(&r, green: &g, blue: &b, alpha: nil)
//			self.red = r*65535
		}
	}
}

extension SwiftTerm.Color {
	var colorCodable: ColorCodable {
		let red = Double(self.red)/65535
		let green = Double(self.green)/65535
		let blue = Double(self.blue)/65535
		return ColorCodable(red: red, green: green, blue: blue)
	}
	
	var uiColor: UIColor {
		let red = CGFloat(self.red)/65535
		let green = CGFloat(self.green)/65535
		let blue = CGFloat(self.blue)/65535
		return UIColor(red: red, green: green, blue: blue, alpha: 1)
	}
}

extension SwiftTerm.Color {
	convenience init(_ color: SwiftUI.Color) {
		var r: CGFloat = 0; var g: CGFloat = 0; var b: CGFloat = 0; var a: CGFloat = 0
		let uiColor = UIColor(color)
		uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
		
		self.init(red: UInt16(r*65535), green: UInt16(g*65535), blue: UInt16(b*65535))
	}
	
	convenience init(_ colorCodable: ColorCodable) {
		var cc = colorCodable
		if cc.red < 0 { cc.red.negate() }
		if cc.green < 0 { cc.green.negate() }
		if cc.blue < 0 { cc.blue.negate() }
		if cc.red > 1 { cc.red = 1 }
		if cc.green > 1 { cc.green = 1 }
		if cc.blue > 1 { cc.blue = 1 }
		
		let red = UInt16(cc.red * 65535)
		let green = UInt16(cc.green * 65535)
		let blue = UInt16(cc.blue * 65535)
		self.init(red: red, green: green, blue: blue)
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
