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
		let tv = TerminalView()
		let terminalDelegate = ShhTerminalViewDelegate()
		tv.terminalDelegate = terminalDelegate
		
		tv.getTerminal().feed(text: handler.readFromChannel())
		return tv
	}
	
	func updateUIView(_ tv: TerminalView, context: Context) {
		tv.getTerminal().feed(text: handler.readFromChannel())
	}
}
