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
	
	var readTimer: Timer?
	
	public convenience init(frame: CGRect, handler: SSHHandler, hostsManager: HostsManager) {
		self.init(frame: frame)
		
		self.handler = handler
		self.hostsManager = hostsManager
	}
	
	override func didMoveToWindow() {
		super.didMoveToWindow()
		if window != nil {
			restoreScrollback()
			if let hostsManager {
				font = UIFont(name: hostsManager.selectedFont, size: hostsManager.fontSize)!
			}
			applySelectedTheme()
			applyScrollbackLength()
			applyCursorType()
			getTerminal().registerOscHandler(code: 133, handler: { _ in })
			getTerminal().setCursorAnimations(CursorAnimations(type: .stretchAndMove, length: 0.2))
			self.startFeedLoop()
			let _ = self.becomeFirstResponder()
		}
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
	
	override func showCursor(source: Terminal) {
		super.showCursor(source: source)
		super.cursorStyleChanged(source: getTerminal(), newStyle: getTerminal().options.cursorStyle)
		print("showcursor called")
	}
	
	override func hideCursor(source: Terminal) {
		super.hideCursor(source: source)
		print("hide cursor called")
	}
	
	func startFeedLoop() {
		guard readTimer == nil else { return }
		readTimer = Timer(timeInterval: 0.01, repeats: true) { timer in
			Task(priority: .high) { @MainActor in
				guard let handler = self.handler else { return }
				guard let sessionID = handler.sessionID else { return }
				if let read = handler.readFromChannel() {
					Task { @MainActor in
						self.feed(text: read)
					}
				}
				if !TerminalViewContainer.shared.sessionIDs.contains(sessionID) {
					Task(priority: .high) { @MainActor in
						TerminalViewContainer.shared.sessions[sessionID] = TerminalContainer(handler: handler, terminalView: self)
					}
				}
			}
		}
		RunLoop.main.add(readTimer!, forMode: .common)
	}
	
	func applySelectedTheme() {
		guard let hostsManager else { return }
		applyTheme(hostsManager.selectedTheme)
	}
	
	func applyCursorType() {
		guard let hostsManager else { return }
		getTerminal().setCursorStyle(hostsManager.settings.cursorType.stCursorStyle)
	}
	
	func applyTheme(_ theme: Theme) {
		getTerminal().installPalette(colors: theme.ansi)
		getTerminal().foregroundColor = theme.foreground
		getTerminal().backgroundColor = theme.background
		
		setCursorColor(source: getTerminal(), color: theme.cursor, textColor: theme.cursorText)
		selectedTextBackgroundColor = theme.selection.uiColor
		// TODO: selectedtext color
	}
	
	func applyScrollbackLength() {
		guard let scrollback = hostsManager?.settings.scrollback else {
			print("hey!")
			print("scrollback not found, setting to 1,000")
			getTerminal().options.scrollback = 1_000
			return
		}
		getTerminal().options.scrollback = Int(scrollback)
		print("set scrollback to \(Int(scrollback))")
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
