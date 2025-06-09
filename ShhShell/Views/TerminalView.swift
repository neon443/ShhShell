//
//  TerminalView.swift
//  ShhShell
//
//  Created by neon443 on 09/06/2025.
//

import SwiftUI
import Runestone

struct TerminalView: View {
	@ObservedObject var handler: SSHHandler
	
    var body: some View {
		TextViewController(text: $handler.host.address)
    }
}

#Preview {
    TerminalView(handler: SSHHandler(host: debugHost()))
}
