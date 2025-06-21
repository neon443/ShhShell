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
	@ObservedObject var handler: SSHHandler
	
	func makeUIView(context: Context) -> TextView {
		let languageMode = TreeSitterLanguageMode(language: .bash)
		let textView = TextView()
		setTextViewState(on: textView)
		
		var editorDelegate = textView.editorDelegate
		editorDelegate = TerminalViewDelegate(handler: handler)
		textView.editorDelegate = editorDelegate
		
		textView.translatesAutoresizingMaskIntoConstraints = false
		textView.backgroundColor = .systemBackground
		return textView
	}
	
	func updateUIView(_ textView: TextView, context: Context) {
		textView.text = handler.terminal
	}
	
	private func setTextViewState(on textView: TextView) {
		let text = handler.terminal
		DispatchQueue.global(qos: .userInitiated).async {
			let state = TextViewState(text: text, language: .bash)
			DispatchQueue.main.async {
				textView.setState(state)
			}
		}
	}
}

class TerminalViewDelegate: TextViewDelegate {
	@ObservedObject var handler: SSHHandler
	
	init(handler: SSHHandler) {
		self.handler = handler
	}
	
	func textViewDidChangeGutterWidth(_ textView: TextView) {
		print(textView.gutterWidth)
	}
	
	func textViewDidChange(_ textView: TextView) {
		handler.writeToChannel(textView.text)
	}
	
	func textView(_ textView: TextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
		print(range)
		print(text)
		return true
	}
	
	func textViewShouldBeginEditing(_ textView: TextView) -> Bool {
		print("can edit")
		return true
	}
	
	func textView(_ textView: TextView, shouldInsert characterPair: any CharacterPair, in range: NSRange) -> Bool {
		return false
	}
}
