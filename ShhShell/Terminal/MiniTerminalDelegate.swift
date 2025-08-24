//
//  MiniTerminalDelegate.swift
//  ShhShell
//
//  Created by neon443 on 23/08/2025.
//

import Foundation
import UIKit
import SwiftUI
import SwiftTerm

@MainActor
class MiniTerminalDelegate: TerminalView, TerminalViewDelegate {
	func setCursorType(_ style: CursorType) {
		getTerminal().setCursorStyle(style.stCursorStyle)
	}
	
	nonisolated public func sizeChanged(source: TerminalView, newCols: Int, newRows: Int) {}
	nonisolated public func setTerminalTitle(source: TerminalView, title: String) {}
	nonisolated public func hostCurrentDirectoryUpdate(source: TerminalView, directory: String?) {}
	nonisolated public func send(source: TerminalView, data: ArraySlice<UInt8>) {}
	nonisolated public func scrolled(source: TerminalView, position: Double) {}
	nonisolated public func requestOpenLink(source: SwiftTerm.TerminalView, link: String, params: [String : String]) {}
	nonisolated public func bell(source: TerminalView) {}
	nonisolated public func clipboardCopy(source: SwiftTerm.TerminalView, content: Data) {}
	nonisolated public func iTermContent (source: TerminalView, content: ArraySlice<UInt8>) {}
	nonisolated public func rangeChanged(source: SwiftTerm.TerminalView, startY: Int, endY: Int) {}
	
	public convenience required override init(frame: CGRect) {
		self.init(frame: .zero)
		terminalDelegate = self
	}
	
	public convenience required init?(coder: NSCoder) {
		fatalError("unimplememented")
	}
}
