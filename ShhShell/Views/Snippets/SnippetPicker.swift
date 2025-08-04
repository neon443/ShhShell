//
//  SnippetPicker.swift
//  ShhShell
//
//  Created by neon443 on 03/08/2025.
//

import SwiftUI

struct SnippetPicker: View {
	@ObservedObject var hostsManager: HostsManager
	var callback: ((Snippet) -> Void)?
	
	@Environment(\.dismiss) var dismiss
	
    var body: some View {
		NavigationStack {
			List {
				if hostsManager.snippets.isEmpty {
					Text("No Snippets")
						.font(.headline)
						.monospaced()
				}
				ForEach(hostsManager.snippets) { snip in
					Text(snip.name)
						.onTapGesture {
							dismiss()
							callback?(snip)
						}
				}
			}
			.toolbar {
				Button() {
					dismiss()
				} label: {
					Image(systemName: "xmark")
				}
			}
			.listStyle(.grouped)
		}
    }
}

#Preview {
    SnippetPicker(hostsManager: HostsManager(), callback: nil)
}
