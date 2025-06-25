//
//  CenteredLabel.swift
//  ShhShell
//
//  Created by neon443 on 25/06/2025.
//

import SwiftUI

struct CenteredLabel: View {
	@State var title: String
	@State var systemName: String
    var body: some View {
		HStack {
			Spacer()
			Image(systemName: systemName)
			Text(title)
			Spacer()
		}
    }
}

#Preview {
    CenteredLabel(title: "Button Text Labek", systemName: "pencil.tip.crop.circle")
}
