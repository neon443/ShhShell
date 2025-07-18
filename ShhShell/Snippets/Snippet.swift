//
//  Snippet.swift
//  ShhShell
//
//  Created by neon443 on 18/07/2025.
//

import Foundation

struct Snippet: Codable, Hashable, Identifiable {
	var id: UUID = UUID()
	var name: String
	var content: String
}
