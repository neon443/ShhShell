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
	
	final class TerminalViewContainer {
		@MainActor static var shared: SSHTerminalDelegate?
	}
	
	func makeUIView(context: Context) -> TerminalView {
		if let existing = TerminalViewContainer.shared {
			return existing
		}
		
		let tv = SSHTerminalDelegate(
			frame: CGRect(origin: CGPoint(x: 0, y: 0), size: .zero),
			handler: handler,
			hostsManager: hostsManager
		)
		tv.translatesAutoresizingMaskIntoConstraints = false
		tv.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		
		TerminalViewContainer.shared = tv
		
		return tv
	}
	
	func updateUIView(_ tv: TerminalView, context: Context) {
		tv.setNeedsLayout()
		tv.layoutIfNeeded()
	}
}
