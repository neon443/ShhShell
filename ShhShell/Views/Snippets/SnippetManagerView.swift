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
					if hostsManager.snippets.isEmpty {
						VStack(alignment: .leading) {
							Image(systemName: "questionmark.square.dashed")
								.resizable().scaledToFit()
								.frame(width: 75)
								.foregroundStyle(hostsManager.tint)
								.shadow(color: hostsManager.tint, radius: 2)
								.padding(.bottom, 10)
							Text("No Snippets")
								.font(.title)
								.monospaced()
							Text("Snippets are strings of commands that can be run at once in a terminal.")
								.padding(.bottom)
								.foregroundStyle(.gray)
								.foregroundStyle(.foreground.opacity(0.7))
						}
					}
					ForEach(hostsManager.snippets) { snip in
						VStack(alignment: .leading) {
							Text(snip.name)
								.bold()
								.foregroundStyle(.gray)
								.font(.subheadline)
							Text(snip.content)
								.lineLimit(3)
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
							Button {
								UIPasteboard().string = snip.content
							} label: {
								Label("Copy", systemImage: "doc.on.clipboard")
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

