//
//  SnippetManagerView.swift
//  ShhShell
//
//  Created by neon443 on 18/07/2025.
//

import SwiftUI

struct SnippetManagerView: View {
	@ObservedObject var hostsManager: HostsManager
	
    var body: some View {
		ForEach(hostsManager.snippets) { snip in
			Text(snip.name)
				.bold()
				.font(.subheadline)
			Text(snip.content)
		}
		.toolbar {
			
		}
    }
}

#Preview {
    SnippetManagerView(hostsManager: HostsManager())
}

