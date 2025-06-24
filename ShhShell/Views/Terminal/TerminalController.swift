//
//  TerminalController.swift
//  ShhShell
//
//  Created by neon443 on 21/06/2025.
//

import Foundation
import UIKit
import SwiftUI
import SwiftTerm

struct TerminalController: UIViewRepresentable {
	@ObservedObject var handler: SSHHandler
	
	func makeUIView(context: Context) -> TerminalView {
		let tv = SSHTerminalView(
			frame: CGRect(
				origin: CGPoint(x: 0, y: 0),
				size: .zero
			),
			handler: handler
		)
		
		return tv
	}
	
	func updateUIView(_ tv: TerminalView, context: Context) {
	}
}
