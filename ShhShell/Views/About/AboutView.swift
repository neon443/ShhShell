//
//  AboutView.swift
//  ShhShell
//
//  Created by neon443 on 02/08/2025.
//

import SwiftUI

struct AboutView: View {
	@ObservedObject var hostsManager: HostsManager
	
    var body: some View {
		ZStack {
			hostsManager.selectedTheme.background.suiColor.opacity(0.7)
							.ignoresSafeArea(.all)
			List {
				HStack {
					UIImage().appIcon
						.resizable().scaledToFit()
						.frame(width: 100)
						.clipShape(RoundedRectangle(cornerRadius: 26))
					Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
				}
			}
			.scrollContentBackground(.hidden)
		}
    }
}

#Preview {
    AboutView(hostsManager: HostsManager())
}
