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
	
	@State var historyLimit: Int = 1
	var historyLimitDisplay: String {
		let count = hostsManager.history.count
		if historyLimit == 0 {
			return "\(count) item\(plural(count))"
		} else if historyLimit > count {
			return "\(count)/\(count)"
		} else {
			return "\(historyLimit)/\(count)"
		}
	}
	
	var body: some View {
		if !hostsManager.history.isEmpty {
			Section("Recents") {
				ForEach(hostsManager.history.reversed().prefix(historyLimit)) { history in
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
				HStack(alignment: .center) {
					Button() {
						var decrement: Int = 2
						if historyLimit < 2 { decrement = 1 }
						withAnimation(.spring) { historyLimit -= decrement }
					} label: {
						Image(systemName: "chevron.up")
							.resizable().scaledToFit()
							.frame(width: 20)
							.foregroundStyle(hostsManager.tint)
					}
					.buttonStyle(.plain)
					.disabled(historyLimit == 0)
					.padding(.trailing, 10)
					
					Button() {
						withAnimation(.spring) { historyLimit += 2 }
					} label: {
						Image(systemName: "chevron.down")
							.resizable().scaledToFit()
							.frame(width: 20)
							.foregroundStyle(hostsManager.tint)
					}
					.buttonStyle(.plain)
					.disabled(historyLimit >= hostsManager.history.count)
					
					Spacer()
					Text(historyLimitDisplay)
					.foregroundStyle(.gray)
					.font(.caption)
					.contentTransition(.numericText())
					Spacer()
					
					Button {
						withAnimation(.spring) { historyLimit = Int.max }
					} label: {
						Image(systemName: "rectangle.expand.vertical")
							.resizable().scaledToFit()
							.frame(width: 20)
							.foregroundStyle(hostsManager.tint)
					}
					.buttonStyle(.plain)
					.disabled(historyLimit != 0)
					.padding(.trailing, 10)
					
					Button {
						withAnimation(.spring) { historyLimit = 0 }
					} label: {
						Image(systemName: "rectangle.compress.vertical")
							.resizable().scaledToFit()
							.frame(width: 20)
							.foregroundStyle(hostsManager.tint)
					}
					.buttonStyle(.plain)
					.disabled(historyLimit == 0)
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
