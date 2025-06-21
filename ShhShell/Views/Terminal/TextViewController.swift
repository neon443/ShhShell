//
//  TextViewController.swift
//  ShhShell
//
//  Created by neon443 on 09/06/2025.
//

import Foundation
import UIKit
import SwiftUI
import Runestone
import TreeSitterBashRunestone

struct TextViewController: UIViewRepresentable {
	@Binding var text: String
	
	func makeUIView(context: Context) -> TextView {
		let languageMode = TreeSitterLanguageMode(language: .bash)
		let textView = TextView()
		setTextViewState(on: textView)
		textView.translatesAutoresizingMaskIntoConstraints = false
		textView.backgroundColor = .systemBackground
		return textView
	}
	
	func updateUIView(_ textView: TextView, context: Context) {
		textView.text = text
	}
	
	private func setTextViewState(on textView: TextView) {
		DispatchQueue.global(qos: .userInitiated).async {
			let text = self.text
			let state = TextViewState(text: text, language: .bash)
			DispatchQueue.main.async {
				textView.setState(state)
			}
		}
	}
}
