//
//  AddSnippetView.swift
//  ShhShell
//
//  Created by neon443 on 22/07/2025.
//

import SwiftUI

struct AddSnippetView: View {
	@ObservedObject var hostsManager: HostsManager
	@State var name: String = ""
	@State var content: String = ""
	
	var snippet: Snippet {
		Snippet(name: name, content: content)
	}
	
	@Environment(\.dismiss) var dismiss
	@Environment(\.colorScheme) var colorScheme
	
    var body: some View {
		NavigationStack {
			List {
				TextBox(label: "Name", text: $name, prompt: "")
				
				VStack {
					Text("Content")
						.padding(.top)
						.foregroundStyle(.gray)
						.listRowSeparator(.hidden)
						.multilineTextAlignment(.leading)
						.frame(maxWidth: .infinity, alignment: .leading)
					TextEditor(text: $content)
						.autocorrectionDisabled()
						.textInputAutocapitalization(.never)
//						.background(.black)
						.clipShape(RoundedRectangle(cornerRadius: 5))
						.padding(.bottom)
						.frame(minHeight: 50)
				}
				.toolbar {
					ToolbarItem(placement: .topBarLeading) {
						Button {
							dismiss()
						} label: {
							Label("Cancel", systemImage: "xmark")
						}
					}
					ToolbarItem(placement: .topBarTrailing) {
						Button {
							hostsManager.addSnippet(snippet)
							dismiss()
						} label: {
							Label("Add", systemImage: "plus")
						}
						.disabled(name.isEmpty || content.isEmpty)
					}
				}
			}
		}
    }
}

#Preview {
	AddSnippetView(hostsManager: HostsManager())
}
