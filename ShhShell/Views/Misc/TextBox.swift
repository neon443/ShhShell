//
//  TextBoxWLabel.swift
//  ShhShell
//
//  Created by neon443 on 30/06/2025.
//

import SwiftUI

struct TextBox: View {
	@State var label: String
	@Binding var text: String
	@State var prompt: String
	@State var secure: Bool = false
	@State var keyboardType: UIKeyboardType = .default
	
    var body: some View {
		HStack {
			Text(label)
			if secure {
				SecureField("", text: $text, prompt: Text(prompt))
					.multilineTextAlignment(.trailing)
			} else {
				TextField("", text: $text, prompt: Text(prompt))
					.multilineTextAlignment(.trailing)
					.disableAutocorrection(true)
					.textInputAutocapitalization(.never)
			}
		}
    }
}

#Preview {
	TextBox(label: "Label", text: .constant("asdflkajsdl"), prompt: "")
}
