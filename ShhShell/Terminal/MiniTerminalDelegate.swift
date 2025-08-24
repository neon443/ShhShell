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
	var text: String = ""
	var cursorType = CursorType()
	var hasConfigured: Bool = false
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		if !hasConfigured && bounds.width > 0 && bounds.height > 0 {
			self.getTerminal().resetNormalBuffer()
			self.getTerminal().resetToInitialState()
			self.getTerminal().softReset()
			self.feed(text: "")
			self.getTerminal().setCursorStyle(CursorStyle.blinkBar)
			hasConfigured = true
		}
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
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		terminalDelegate = self
	}
	
	public convenience required init?(coder: NSCoder) {
		fatalError("unimplememented")
	}
}
