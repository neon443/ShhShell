//
//  RecentsView.swift
//  ShhShell
//
//  Created by neon443 on 14/08/2025.
//

import SwiftUI

struct RecentsView: View {
	@ObservedObject var hostsManager: HostsManager
	@ObservedObject var keyManager: KeyManager
	
	@State var historyCount: Int = 1
	
    var body: some View {
		if !hostsManager.history.isEmpty {
			Section("Recents") {
				ForEach(0..<historyCount, id: \.self) { index in
					let history = hostsManager.history[index]
					NavigationLink() {
						ConnectionView(
							handler: SSHHandler(
								host: history.host,
								keyManager: keyManager
							),
							hostsManager: hostsManager,
							keyManager: keyManager
						)
					} label: {
						Text("\(history.count)")
							.foregroundStyle(.gray)
							.padding(.trailing, 10)
							.font(.caption)
						VStack(alignment: .leading) {
							Text(history.host.description)
								.font(.body)
							Text("Last connected at " + history.lastConnect.formatted())
								.font(.caption)
								.foregroundStyle(.gray)
						}
					}
					.swipeActions {
						Button("Remove", systemImage: "trash", role: .destructive) {
							hostsManager.removeFromHistory(history)
						}
						.tint(.red)
					}
				}
				if historyCount <= hostsManager.history.count {
					HStack(alignment: .center) {
						Button() {
							var increment = 2
							if historyCount+2 > hostsManager.history.count {
								increment = 1
							}
							withAnimation { historyCount += increment }
						} label: {
							Image(systemName: "chevron.down")
								.resizable().scaledToFit()
								.frame(width: 20)
								.foregroundStyle(hostsManager.tint)
						}
						.buttonStyle(.plain)
						.disabled(historyCount == hostsManager.history.count)
						
						Spacer()
						Text(
							historyCount == 0 ?
							"\(hostsManager.history.count) item\(plural(hostsManager.history.count))" :
								"\(historyCount)/\(hostsManager.history.count)"
						)
						.foregroundStyle(.gray)
						.font(.caption)
						.contentTransition(.numericText())
						Spacer()
						
						Button {
							withAnimation { historyCount = 0 }
						} label: {
							Image(systemName: "chevron.up.2")
								.resizable().scaledToFit()
								.frame(width: 20)
								.foregroundStyle(hostsManager.tint)
						}
						.buttonStyle(.plain)
						.disabled(historyCount == 0)
					}
				}
				
			}
			.transition(.opacity)
		}
    }
}

#Preview {
	RecentsView(
		hostsManager: HostsManager(),
		keyManager: KeyManager()
	)
}

func plural(_ num: Int) -> String {
	return num == 1 ? "" : "s"
}
