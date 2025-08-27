//
//  WelcomeChunk.swift
//  ShhShell
//
//  Created by neon443 on 27/08/2025.
//

import SwiftUI

struct WelcomeChunk: View {
	@State var symbol: String
	@State var title: String
	@State var para: String
	@State var timeTarget: TimeInterval = 0
	
	@State private var spawnDate: Date = .now
	
	var body: some View {
		TimelineView(.animation) { tl in
			let time = tl.date.timeIntervalSince(spawnDate)
			HStack {
				if time > timeTarget {
					Image(systemName: symbol)
						.resizable().scaledToFit()
						.frame(width: 50)
				}
				VStack(alignment: .leading) {
					if time > timeTarget+1 {
						Text(title)
							.bold()
							.font(.headline)
						Text(para)
							.foregroundStyle(.gray)
							.multilineTextAlignment(.leading)
					}
				}
				Spacer()
			}
			.animation(.spring, value: time)
			.frame(maxWidth: .infinity)
			.padding(.horizontal, 50)
		}
	}
}

#Preview {
	WelcomeChunk(
		symbol: "trash",
		title: "The Trash",
		para: "Here's to the crazy ones."
	)
}
