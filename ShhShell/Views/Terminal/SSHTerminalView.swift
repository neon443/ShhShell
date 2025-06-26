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
final class SSHTerminalView: TerminalView, Sendable, @preconcurrency TerminalViewDelegate {
	var handler: SSHHandler?
	var sshQueue = DispatchQueue(label: "sshQueue")
	var resuming: Bool
	
	public convenience init(frame: CGRect, handler: SSHHandler, resuming: Bool) {
		self.init(frame: frame)
		self.handler = handler
		self.resuming = resuming
		
		sshQueue.async {
			Task {
				if resuming {
					if let handler = await self.handler {
						for chunk in handler.scrollback {
							await MainActor.run {
								self.feed(text: chunk)
							}
						}
					}
				}
			}
		}

		sshQueue.async {
			Task {
				guard let handler = await self.handler else { return }
				while handler.connected {
					if let read = handler.readFromChannel() {
						await MainActor.run {
							self.feed(text: read)
						}
					} else {
						try? await Task.sleep(nanoseconds: 10_000_000) //10ms
					}
				}
				handler.disconnect()
			}
		}
	}
	
	public override init(frame: CGRect) {
		self.resuming = false
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
