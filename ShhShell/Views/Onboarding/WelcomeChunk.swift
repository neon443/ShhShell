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
	@State var delay: TimeInterval = 0
	
	@State private var spawnDate: Date = .now
	
	var body: some View {
		TimelineView(.animation) { tl in
			let time = tl.date.timeIntervalSince(spawnDate)
			HStack(spacing: 25) {
				if time > delay {
					Image(systemName: symbol)
						.resizable().scaledToFit()
						.symbolRenderingMode(.hierarchical)
						.frame(width: 50, height: 50)
						.transition(.scale)
				}
				VStack(alignment: .leading) {
					if time > delay+0.25 {
						Text(title)
							.bold()
							.font(.headline)
							.transition(.blurReplace)
					}
					if time > delay+0.75 && !para.isEmpty {
						Text(para)
							.foregroundStyle(.gray)
							.font(.footnote)
							.transition(.blurReplace)
							.lineLimit(nil)
							.multilineTextAlignment(.leading)
					}
				}
				.shadow(color: .white, radius: time > delay+0.75 ? 0 : 5)
				
				Spacer()
			}
			.animation(.spring, value: time)
			.frame(maxWidth: .infinity)
			.padding(.horizontal, 30)
			.padding(10)
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
