//
//  ViewModifiers.swift
//  ShhShell
//
//  Created by neon443 on 08/06/2025.
//

import Foundation
import SwiftUI

struct glassButton: ViewModifier {
	var prominent: Bool
	
	init(prominent: Bool = false) {
		self.prominent = prominent
	}
	
	func body(content: Content) -> some View {
		if #available(iOS 26, *) {
			if prominent {
				content.buttonStyle(.glassProminent)
			} else {
				content.buttonStyle(.glass)
			}
		} else {
			content
		}
	}
}

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

struct presentationCompactPopover: ViewModifier {
	func body(content: Content) -> some View {
		if #available(iOS 16.4, *) {
			content.presentationCompactAdaptation(.popover)
		} else {
			content
		}
	}
}

struct scrollPaging: ViewModifier {
	func body(content: Content) -> some View {
		if #available(iOS 17, *) {
			content.scrollTargetBehavior(.paging)
		} else {
			content
		}
	}
}

struct scrollTargetLayoutt: ViewModifier {
	func body(content: Content) -> some View {
		if #available(iOS 17, *) {
			content.scrollTargetLayout()
		} else {
			content
		}
	}
}

struct contentMarginss: ViewModifier {
	var length: CGFloat
	
	init(length: CGFloat) {
		self.length = length
	}
	
	func body(content: Content) -> some View {
		if #available(iOS 17, *) {
			content.contentMargins(length)
		} else {
			content
		}
	}
}
