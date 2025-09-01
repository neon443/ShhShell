//
//  WelcomeChunk.swift
//  ShhShell
//
//  Created by neon443 on 27/08/2025.
//

import SwiftUI

struct WelcomeChunk: View {
	@State var systemImage: String?
	@State var image: String?
	@State var title: String
	@State var para: String
	@State var delay: TimeInterval = 0
	
	@State private var spawnDate: Date = .now
	
	var imageUnwrapped: Image {
		if let systemImage {
			return Image(systemName: systemImage)
		} else if let image {
			return Image(image)
		} else {
			return Image(systemName: "questionmark")
		}
	}
	
	var body: some View {
		TimelineView(.animation) { tl in
			let time = tl.date.timeIntervalSince(spawnDate)
			HStack(spacing: 25) {
				if time > delay {
					imageUnwrapped
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
							.transition(.opacity)
					}
					if time > delay+0.75 && !para.isEmpty {
						Text(para)
							.foregroundStyle(.gray)
							.font(.footnote)
							.transition(.opacity)
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
		systemImage: "trash",
		title: "The Trash",
		para: "Here's to the crazy ones."
	)
}
