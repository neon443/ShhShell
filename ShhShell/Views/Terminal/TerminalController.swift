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
	@ObservedObject var hostsManager: HostsManager
	
	@ObservedObject var container = TerminalViewContainer.shared
	
	func makeUIView(context: Context) -> TerminalView {
		if let sessionID = handler.sessionID {
			if let existing = container.sessions[sessionID] {
				Task {
					await existing.terminalView.restoreScrollback()
				}
				return existing.terminalView
			}
		}
		
		let tv = SSHTerminalDelegate(
			frame: CGRect(origin: CGPoint(x: 0, y: 0), size: .zero),
			handler: handler,
			hostsManager: hostsManager
		)
		tv.translatesAutoresizingMaskIntoConstraints = false
		tv.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		
		if let sessionID = handler.sessionID {
			Task { @MainActor in
				container.sessions[sessionID] = TerminalContainer(
					handler: handler,
					terminalView: tv
				)
			}
		}
		
		return tv
	}
	
	func updateUIView(_ tv: TerminalView, context: Context) {
		tv.setNeedsLayout()
		tv.layoutIfNeeded()
	}
}
