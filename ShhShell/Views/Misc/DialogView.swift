//
//  DialogView.swift
//  ShhShell
//
//  Created by neon443 on 24/06/2025.
//

import SwiftUI

struct DialogView: View {
	@ObservedObject var handler: SSHHandler
	@State var showDialog: Bool
	@State var icon: String = "network.slash"
	@State var headline: String = "Disconnected"
	@State var text: String = "Connection to the SSH server has been lost, try reconnecting"
	
    var body: some View {
		GeometryReader { geo in
			let width = geo.size.width*0.75
			let height = geo.size.height*0.15
			if showDialog {
				ZStack(alignment: .center) {
					Color.black
						.clipShape(RoundedRectangle(cornerRadius: 15))
						.frame(maxWidth: width, maxHeight: height)
						.shadow(color: .white, radius: 2)
					HStack(alignment: .top) {
						Image(systemName: icon)
							.resizable().scaledToFit()
							.frame(width: width*0.2)
							.foregroundStyle(.terminalGreen)
							.symbolRenderingMode(.hierarchical)
						VStack(alignment: .leading) {
							Text(headline)
								.foregroundStyle(.terminalGreen)
								.font(.title2)
								.bold()
							Text(text)
								.foregroundStyle(.terminalGreen)
								.font(.footnote)
						}
						.frame(width: width*0.7)
					}
					.frame(maxWidth: width, maxHeight: height)
				}
				.transition(
					.asymmetric(
						insertion: .move(edge: .bottom),
						removal: .move(edge: .bottom)
					)
					.combined(with: .opacity)
				)
				.frame(maxWidth: .infinity, maxHeight: .infinity)
			}
		}
	}
}

#Preview {
	ZStack {
		Color.black
		DialogView(handler: SSHHandler(host: Host.debug, keyManager: nil), showDialog: true)
	}
}
