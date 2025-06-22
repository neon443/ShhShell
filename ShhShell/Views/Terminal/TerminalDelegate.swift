//
//  TerminalDelegate.swift
//  ShhShell
//
//  Created by neon443 on 21/06/2025.
//

import Foundation
import SwiftTerm

class ShhTerminalViewDelegate: TerminalViewDelegate {
	func sizeChanged(source: TerminalView, newCols: Int, newRows: Int) {
		print(newRows, newCols)
	}
	
	func setTerminalTitle(source: TerminalView, title: String) {
		print(title)
	}
	
	func hostCurrentDirectoryUpdate(source: TerminalView, directory: String?) {
		print(directory)
	}
	
	func send(source: TerminalView, data: ArraySlice<UInt8>) {
		print(data)
	}
	
	func scrolled(source: TerminalView, position: Double) {
		print(position)
	}
	
	func requestOpenLink(source: TerminalView, link: String, params: [String : String]) {
		print(link)
		print(params)
	}
	
	func bell(source: TerminalView) {
		print("ding")
	}
	
	func clipboardCopy(source: TerminalView, content: Data) {
		print(content)
	}
	
	func iTermContent(source: TerminalView, content: ArraySlice<UInt8>) {
		print("idk what this does")
	}
	
	func rangeChanged(source: TerminalView, startY: Int, endY: Int) {
		print(startY, endY)
	}
}
