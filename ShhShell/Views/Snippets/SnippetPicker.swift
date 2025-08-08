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
	
	@State var showAdder: Bool = false
	
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
					Button(snip.name) {
						dismiss()
						callback?(snip)
					}
				}
				
				Section {
					Button() {
						showAdder.toggle()
					} label: {
						Label("Add", systemImage: "plus.circle.fill")
					}
				}
			}
			.sheet(isPresented: $showAdder) {
				AddSnippetView(hostsManager: hostsManager)
			}
			.toolbar {
				ToolbarItem(placement: .topBarLeading) {
					Button() {
						dismiss()
					} label: {
						Image(systemName: "xmark")
					}
				}
			}
			.listStyle(.grouped)
		}
    }
}

#Preview {
    SnippetPicker(hostsManager: HostsManager(), callback: nil)
}
