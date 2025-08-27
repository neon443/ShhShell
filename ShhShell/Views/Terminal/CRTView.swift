//
//  CRTView.swift
//  ShhShell
//
//  Created by neon443 on 25/08/2025.
//

import SwiftUI

struct CRTView: View {
	@State var startTime: Date = .now
	
	var body: some View {
		TimelineView(.animation) { tl in
			let time = tl.date.distance(to: startTime)
			Rectangle()
				.foregroundStyle(.black.opacity(1))
				.visualEffect { content, proxy in
					content
						.colorEffect(
							ShaderLibrary.crt(
								.float2(proxy.size),
								.float(time)
							)
						)
				}
		}
	}
}

#Preview {
    CRTView()
}
