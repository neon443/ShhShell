//
//  AboutView.swift
//  ShhShell
//
//  Created by neon443 on 02/08/2025.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
		HStack {
			UIImage().appIcon
			Image(uiImage: UIImage(named: "AppIcon") ?? UIImage())
			Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
		}
    }
}

#Preview {
    AboutView()
}
