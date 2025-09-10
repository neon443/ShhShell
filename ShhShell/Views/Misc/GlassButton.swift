//
//  GlassButton.swift
//  ShhShell
//
//  Created by neon443 on 10/09/2025.
//

import SwiftUI

struct GlassButton<Label: View>: View {
	var action: (() -> Void)
	var prominent: Bool = false
	@ViewBuilder var label: Label
	@ViewBuilder var fallbackLabel: Label
	
    var body: some View {
		if #available(iOS 26, *) {
			Button {
				action()
			} label: {
				label
			}
			.buttonStyle(.glassProminent)
		} else {
			Button {
				action()
			} label: {
				fallbackLabel
			}
		}
    }
}

#Preview {
	GlassButton(
		action: {
			
		},
		prominent: true,
		label: {
			Text("iOS 26+")
				.padding(5)
		},
		fallbackLabel: {
			Text("iOS 26+")
				.padding(5)
		}
	)
}
