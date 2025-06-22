//
//  SSHTerminalView.swift
//  ShhShell
//
//  Created by neon443 on 21/06/2025.
//

import Foundation
import SwiftTerm

class SSHTerminalView: TerminalView, TerminalViewDelegate {
	var handler: SSHHandler?
	var sshQueue: DispatchQueue
	
	public convenience init(frame: CGRect, handler: SSHHandler) {
		self.init(frame: frame)
		self.handler = handler
	}
	
	public override init(frame: CGRect) {
		sshQueue = DispatchQueue(label: "sshQueue")
		
		super.init(frame: frame)
		terminalDelegate = self
		sshQueue.async {
			guard let handler = self.handler else { return }
			while handler.connected {
				guard let handler = self.handler else { break }
				if let read = handler.readFromChannel() {
					DispatchQueue.main.async {
						self.feed(text: read)
					}
				} else {
					usleep(10_000)
				}
			}
		}
	}
	
	required init?(coder: NSCoder) {
		fatalError("unimplemented")
	}

	public func scrolled(source: TerminalView, position: Double) {
		print("scrolled to \(position)")
	}
	
	public func setTerminalTitle(source: TerminalView, title: String) {
		print("set title to \(title)")
	}
	
	public func sizeChanged(source: TerminalView, newCols: Int, newRows: Int) {
		handler?.resizeTTY(toRows: newRows, toCols: newCols)
	}
	
	public func send(source: TerminalView, data: ArraySlice<UInt8>) {
		let data = Data(data)
//		let dataSlice = Data(bytes: [data], count: data.count)
		print("sending \(String(data: data, encoding: .utf8))")
		handler?.writeToChannel(String(data: data, encoding: .utf8))
	}
	
	public func clipboardCopy(source: TerminalView, content: Data) {
		print(content)
	}
	
	public func hostCurrentDirectoryUpdate(source: TerminalView, directory: String?) {
		print("new dir: \(directory ?? "")")
	}
	
	public func requestOpenLink(source: TerminalView, link: String, params: [String : String]) {
		print("open link \(link) \(params)")
	}
	
	public func rangeChanged(source: TerminalView, startY: Int, endY: Int) {
		print(startY, endY)
	}
}
