//
//  History.swift
//  ShhShell
//
//  Created by neon443 on 15/08/2025.
//

import Foundation

struct History: Identifiable, Codable {
	var id: UUID = UUID()
	
	var host: Host
	var count: Int
	var lastConnect: Date = .now
}
