//
//  ColorCodable.swift
//  ShhShell
//
//  Created by neon443 on 29/06/2025.
//

import Foundation
import SwiftTerm
import SwiftUI

struct ColorCodable: Codable, Hashable, Equatable {
	var red: Double
	var green: Double
	var blue: Double
	
	enum CodingKeys: String, CodingKey {
		case red = "Red Component"
		case green = "Green Component"
		case blue = "Blue Component"
	}
	
	init(red: Double, green: Double, blue: Double) {
		self.red = red
		self.green = green
		self.blue = blue
	}
	
	init(color: SwiftUI.Color) {
		let uiColor = UIColor(color)
		var r: CGFloat = 0
		var g: CGFloat = 0
		var b: CGFloat = 0
		uiColor.getRed(&r, green: &g, blue: &b, alpha: nil)
		self.red = r
		self.green = g
		self.blue = b
	}
}

extension ColorCodable {
	var suiColor: SwiftUI.Color {
		get {
			let red = CGFloat(self.red)
			let green = CGFloat(self.green)
			let blue = CGFloat(self.blue)
			return Color(UIColor(red: red, green: green, blue: blue, alpha: 1))
		}
		set {
			let cc = ColorCodable(color: newValue)
			self.red = cc.red
			self.green = cc.green
			self.blue = cc.blue
		}
	}
}

extension ColorCodable {
	var stColor: SwiftTerm.Color {
		return SwiftTerm.Color(self)
	}
}
