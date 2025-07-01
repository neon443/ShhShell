//
//  KeyImporterView.swift
//  ShhShell
//
//  Created by neon443 on 01/07/2025.
//

import SwiftUI

struct KeyImporterView: View {
	@ObservedObject var keyManager: KeyManager
	
	@Environment(\.dismiss) var dismiss
	
	@State var keyName: String = UIDevice().model + " " + Date().formatted()
	@State var privkeyStr: String = ""
	@State var keyType: KeyType = .ed25519
	
	var keypair: Keypair {
		Keypair(type: keyType, name: keyName, privateKey: privkeyStr.data(using: .utf8) ?? Data())
	}
	
    var body: some View {
		List {
			TextBox(label: "Name", text: $keyName, prompt: "A name for your key")
			
			Picker("Key type", selection: $keyType) {
				ForEach(KeyType.allCases, id: \.self) { type in
					Text(type.description)
						.tag(type)
				}
			}
			.pickerStyle(SegmentedPickerStyle())
			
			HStack {
				Text("Private Key")
				Spacer()
				Text("Required")
					.foregroundStyle(.red)
			}
			
			TextEditor(text: $privkeyStr)
			
			TextEditor(text: .constant(keypair.openSshPubkey))
			
			Button() {
				keyManager.importKey(type: keyType, priv: privkeyStr, name: keyName)
				dismiss()
			} label: {
				Label("Import", systemImage: "key.horizontal")
			}
			.buttonStyle(.borderedProminent)
		}
    }
}

#Preview {
    KeyImporterView(keyManager: KeyManager())
}
