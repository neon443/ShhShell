//
//  Haptics.swift
//  ShhShell
//
//  Created by neon443 on 26/07/2025.
//

import Foundation
#if canImport(UIKit)
import UIKit

enum Haptic {
	case success
	case warning
	case error
	case light
	case medium
	case heavy
	case soft
	case rigid
	
	var isUIImpact: Bool {
		switch self {
		case .light, .medium, .heavy, .soft, .rigid:
			return true
		case .success, .warning, .error:
			return false
		}
	}
	
	@MainActor
	var uiImpact: UIImpactFeedbackGenerator? {
		guard self.isUIImpact else { return nil }
		switch self {
		case .light, .medium, .heavy, .soft, .rigid:
			switch self {
			case .light:
				return UIImpactFeedbackGenerator(style: .light)
			case .medium:
				return UIImpactFeedbackGenerator(style: .medium)
			case .heavy:
				return UIImpactFeedbackGenerator(style: .heavy)
			case .soft:
				return UIImpactFeedbackGenerator(style: .soft)
			case .rigid:
				return UIImpactFeedbackGenerator(style: .rigid)
			default: return nil
			}
		default: return nil
		}
	}
	
	func trigger() {
		Task { @MainActor in
			if self.isUIImpact {
				self.uiImpact?.impactOccurred()
			} else {
				switch self {
				case .success:
					UINotificationFeedbackGenerator().notificationOccurred(.success)
				case .warning:
					UINotificationFeedbackGenerator().notificationOccurred(.warning)
				case .error:
					UINotificationFeedbackGenerator().notificationOccurred(.error)
				default: print("idk atp")
				}
			}
		}
	}
}
#endif
