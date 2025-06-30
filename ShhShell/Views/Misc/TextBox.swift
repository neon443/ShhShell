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
	@State var secure: Bool = false
	@State var keyboardType: UIKeyboardType = .default
	
    var body: some View {
		HStack {
			Text(label)
			Spacer()
			if secure {
				SecureField("", text: $text)
			} else {
				TextField("", text: $text)
			}
		}
    }
}

#Preview {
	TextBox(label: "Label", text: .constant("asdflkajsdl"))
}
