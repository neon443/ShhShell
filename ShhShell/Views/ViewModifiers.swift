//
//  ViewModifiers.swift
//  ShhShell
//
//  Created by neon443 on 08/06/2025.
//

import Foundation
import SwiftUI

struct foregroundColorStyle: ViewModifier {
	var color: Color
	
	init(_ color: Color) {
		self.color = color
	}
	
	func body(content: Content) -> some View {
		if #available(iOS 15.0, *) {
			content.foregroundStyle(color)
		} else {
			content.foregroundColor(color)
		}
	}
}
