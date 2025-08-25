//
//  ShaderTestingView.swift
//  ShhShell
//
//  Created by neon443 on 25/08/2025.
//

import SwiftUI

struct ShaderTestingView: View {
    var body: some View {
		Image(systemName: "figure.walk.circle")
			.font(.system(size: 300))
			.foregroundStyle(.blue)
			.colorEffect(ShaderLibrary.redify())
    }
}

#Preview {
    ShaderTestingView()
}
