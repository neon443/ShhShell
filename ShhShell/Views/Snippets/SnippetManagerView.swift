//
//  SnippetManagerView.swift
//  ShhShell
//
//  Created by neon443 on 18/07/2025.
//

import SwiftUI

struct SnippetManagerView: View {
	@ObservedObject var hostsManager: HostsManager
	@State var showSnippetAdder: Bool = false
	
    var body: some View {
		ZStack {
			hostsManager.selectedTheme.background.suiColor.opacity(0.7)
				.ignoresSafeArea(.all)
			NavigationStack {
				List {
					ForEach(hostsManager.snippets) { snip in
						Group {
							Text(snip.name)
								.bold()
								.font(.subheadline)
							Text(snip.content)
						}
						.swipeActions(edge: .trailing) {
							Button(role: .destructive) {
								hostsManager.deleteSnippet(snip)
							} label: {
								Label("Delete", systemImage: "trash")
							}
							.tint(.red)
							Button {
								hostsManager.duplicateSnippet(snip)
							} label: {
								Label("Duplicate", systemImage: "square.filled.on.square")
							}
							.tint(.blue)
						}
					}
				}
				.scrollContentBackground(.hidden)
				.sheet(isPresented: $showSnippetAdder) {
					AddSnippetView(hostsManager: hostsManager)
						.presentationDetents([.medium])
				}
				.toolbar {
					Button() {
						showSnippetAdder.toggle()
					} label: {
						Label("Add", systemImage: "plus")
					}
				}
			}
		}
    }
}

#Preview {
    SnippetManagerView(hostsManager: HostsManager())
}

