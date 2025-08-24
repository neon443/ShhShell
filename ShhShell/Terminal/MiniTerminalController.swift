//
//  MiniTerminalController.swift
//  ShhShell
//
//  Created by neon443 on 23/08/2025.
//

import Foundation
import UIKit
import SwiftUI
import SwiftTerm

struct MiniTerminalController: UIViewRepresentable {
	func feed() {
		
	}
	
	func makeUIView(context: Context) -> TerminalView {
		let tv = MiniTerminalDelegate(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: .zero))
		tv.translatesAutoresizingMaskIntoConstraints = true
		tv.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		return tv
	}
	
	func updateUIView(_ tv: TerminalView, context: Context) {
		tv.setNeedsLayout()
		tv.layoutIfNeeded()
	}
}
