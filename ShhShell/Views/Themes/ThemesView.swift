//
//  ThemesView.swift
//  ShhShell
//
//  Created by neon443 on 27/06/2025.
//

import SwiftUI

struct ThemesView: View {
	@ObservedObject var hostsManager: HostsManager
	
    var body: some View {
		ForEach(hostsManager.themes) { theme in
			ZStack {
				RoundedRectangle(cornerRadius: 10)
			}
		}
    }
}

#Preview {
    ThemesView(hostsManager: HostsManager())
}
