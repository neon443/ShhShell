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
	@Binding var text: String
	@Binding var cursorType: CursorType
	
	func makeUIView(context: Context) -> TerminalView {
		let tv = MiniTerminalDelegate(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: .zero))
		tv.translatesAutoresizingMaskIntoConstraints = true
		tv.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		return tv
	}
	
	func updateUIView(_ tv: TerminalView, context: Context) {
		guard let tdelegate = tv as? MiniTerminalDelegate else { return }
		tdelegate.text = text
		tdelegate.cursorType = cursorType
		tv.setNeedsLayout()
		tv.layoutIfNeeded()
		tv.layoutSubviews()
	}
}
