//
//  WelcomeView.swift
//  ShhShell
//
//  Created by neon443 on 27/08/2025.
//

import SwiftUI

struct WelcomeView: View {
	@State private var spawnDate: Date = .now
	var body: some View {
		TimelineView(.animation) { tl in
			let time = tl.date.timeIntervalSince(spawnDate)
#if DEBUG
			Button("reset") { spawnDate = .now }
			Text("\(time)")
				.frame(width: 150, alignment: .leading)
#endif
			
			VStack {
				
				Text("Welcome")
					.monospaced()
					.font(.largeTitle)
					.bold()
				
				if time > 1 {
					Image("regular")
						.resizable().scaledToFit()
						.frame(width: 100)
						.clipShape(RoundedRectangle(cornerRadius: 22))
						.shadow(color: .white, radius: 6)
						.transition(.scale)
						.padding(.bottom)
				}
				if time > 1 {
					WelcomeChunk(symbol: "hare.fill", title: "Blazing fast", para: "hi", timeTarget: 1)
				}
			}
			.animation(.spring, value: time)
			.preferredColorScheme(.dark)
		}
	}
}

#Preview {
	WelcomeView()
}
