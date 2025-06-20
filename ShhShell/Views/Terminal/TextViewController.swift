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

struct TextViewController: UIViewRepresentable {
	@Binding var text: String
	
	func makeUIView(context: Context) -> TextView {
		let textView = TextView()
		textView.translatesAutoresizingMaskIntoConstraints = false
		textView.backgroundColor = .systemBackground
		return textView
	}
	
	func updateUIView(_ textView: TextView, context: Context) {
		textView.text = text
	}
}
