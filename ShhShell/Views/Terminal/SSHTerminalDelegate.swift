//
//  SSHTerminalView.swift
//  ShhShell
//
//  Created by neon443 on 21/06/2025.
//

import Foundation
import UIKit
import SwiftTerm

@MainActor
final class SSHTerminalDelegate: TerminalView, Sendable, @preconcurrency TerminalViewDelegate {
	var handler: SSHHandler?
	var hostsManager: HostsManager?
	
	public convenience init(frame: CGRect, handler: SSHHandler, hostsManager: HostsManager) {
		self.init(frame: frame)
		self.handler = handler
		self.hostsManager = hostsManager
		
		applySelectedTheme()
	}
	
	func restoreScrollback() {
		guard let scrollback = handler?.scrollback else { return }
		guard !scrollback.isEmpty else { return }
		
		DispatchQueue.main.async {
			self.getTerminal().resetToInitialState()
			for line in scrollback {
				self.feed(text: line)
			}
			self.setNeedsLayout()
			self.setNeedsDisplay()
		}
	}
	
	func startFeedLoop() {
		Task {
			guard let handler else { return }
			while checkShell(handler.state) {
				if let read = handler.readFromChannel() {
					await MainActor.run {
						self.feed(text: read)
					}
				} else {
					try? await Task.sleep(nanoseconds: 10_000_000) //10ms
				}
			}
			print("task end?")
		}
	}
	
	func applySelectedTheme() {
		guard let hostsManager else { return }
		applyTheme(hostsManager.selectedTheme)
	}
	
	func applyTheme(_ theme: Theme) {
		getTerminal().installPalette(colors: theme.ansi)
		getTerminal().foregroundColor = theme.foreground
		getTerminal().backgroundColor = theme.background
		
		caretColor = theme.cursor.uiColor
		selectedTextBackgroundColor = theme.selection.uiColor
		
		// TODO: selectedtext and cursor colors
	}
	
	override func didMoveToWindow() {
		super.didMoveToWindow()
		if window != nil {
			restoreScrollback()
		}
	}
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		terminalDelegate = self
	}
	
	required init?(coder: NSCoder) {
		fatalError("unimplemented")
	}
	
	nonisolated public func scrolled(source: TerminalView, position: Double) {}
	
	nonisolated public func setTerminalTitle(source: TerminalView, title: String) {
		Task {
			await MainActor.run { handler?.setTitle(title) }
		}
	}
	
	public func sizeChanged(source: TerminalView, newCols: Int, newRows: Int) {
		try? handler?.resizePTY(toRows: newRows, toCols: newCols)
		setNeedsDisplay()
	}
	
	public func send(source: TerminalView, data: ArraySlice<UInt8>) {
		let data = Data(data)
		handler?.writeToChannel(String(data: data, encoding: .utf8))
	}
	
	nonisolated public func clipboardCopy(source: TerminalView, content: Data) {
		print(content)
	}
	
	nonisolated public func hostCurrentDirectoryUpdate(source: TerminalView, directory: String?) {
		print("new dir: \(directory ?? "")")
	}
	
	public func requestOpenLink(source: TerminalView, link: String, params: [String : String]) {
		guard let url = URL(string: link) else { return }
		guard UIApplication.shared.canOpenURL(url) else { return }
		UIApplication.shared.open(url, options: [:])
	}
	
	nonisolated public func rangeChanged(source: TerminalView, startY: Int, endY: Int) {
		print(startY, endY)
	}
	
	public func bell(source: TerminalView) {
		handler?.ring()
	}
}
