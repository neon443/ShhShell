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
	
	nonisolated public func sizeChanged(source: TerminalView, newCols: Int, newRows: Int) {
		<#code#>
	}
	
	nonisolated public func setTerminalTitle(source: TerminalView, title: String) {
		<#code#>
	}
	
	nonisolated public func hostCurrentDirectoryUpdate(source: TerminalView, directory: String?) {
		<#code#>
	}
	
	nonisolated public func send(source: TerminalView, data: ArraySlice<UInt8>) {
		<#code#>
	}
	
	nonisolated public func scrolled(source: TerminalView, position: Double) {
		<#code#>
	}
	
	nonisolated public func requestOpenLink(source: SwiftTerm.TerminalView, link: String, params: [String : String]) {
		<#code#>
	}
	
	nonisolated public func bell(source: TerminalView) {
		<#code#>
	}
	
	nonisolated public func clipboardCopy(source: SwiftTerm.TerminalView, content: Data) {
		<#code#>
	}
	
	nonisolated public func iTermContent (source: TerminalView, content: ArraySlice<UInt8>) {
		<#code#>
	}
	
	nonisolated public func rangeChanged(source: SwiftTerm.TerminalView, startY: Int, endY: Int) {
		<#code#>
	}
	
	public convenience required override init(frame: CGRect) {
		self.init(frame: .zero)
	}
	
	public convenience required init?(coder: NSCoder) {
		fatalError("unimplememented")
	}
}
