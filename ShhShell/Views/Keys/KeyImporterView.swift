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
	
	@State var keyName: String = UIDevice().model + " at " + Date().formatted(date: .numeric, time: .omitted)
	@State var privkeyStr: String = ""
	@State var keyType: KeyType = .ed25519
	
	var keypair: Keypair {
		Keypair(type: keyType, name: keyName, privateKey: privkeyStr.data(using: .utf8) ?? Data())
	}
	
    var body: some View {
		List {
			TextBox(label: "Name", text: $keyName, prompt: "A name for your key")
			
			HStack {
				Text("Key Type")
				Picker("Key type", selection: $keyType) {
					ForEach(KeyType.allCases, id: \.self) { type in
						Text(type.description)
							.tag(type)
					}
				}
				.pickerStyle(SegmentedPickerStyle())
			}
			
			Section {
				HStack {
					Text("Private Key")
					Spacer()
					Text("Required")
						.foregroundStyle(.red)
				}
				.listRowSeparator(.hidden)
				
				TextEditor(text: $privkeyStr)
					.background(.black)
					.clipShape(RoundedRectangle(cornerRadius: 10))
			}
			
			if !keypair.openSshPubkey.isEmpty {
				Text(keypair.openSshPubkey.trimmingCharacters(in: .whitespacesAndNewlines))
					.foregroundStyle(.gray)
			}
			
		}
		
		Button() {
			keyManager.importKey(type: keyType, priv: privkeyStr, name: keyName)
			dismiss()
		} label: {
			Text("Import")
				.font(.title)
				.bold()
		}
		.onTapGesture {
			UINotificationFeedbackGenerator().notificationOccurred(.success)
		}
		.buttonStyle(.borderedProminent)
		.padding()
    }
}

#Preview {
    KeyImporterView(keyManager: KeyManager())
}
