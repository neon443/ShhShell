//
//  KeyManagerView.swift
//  ShhShell
//
//  Created by neon443 on 20/06/2025.
//

import SwiftUI

struct KeyManagerView: View {
	@ObservedObject var keyManager: KeyManager
	
	var body: some View {
		List {
			Button("ed25519") {
				keyManager.generateEd25519()
			}
			Button("rsa") {
				do {
					try keyManager.generateRSA()
				} catch {
					print(error.localizedDescription)
				}
			}
		}
	}
}

#Preview {
	KeyManagerView(keyManager: KeyManager())
}
