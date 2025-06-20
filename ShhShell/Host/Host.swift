//
//  Host.swift
//  ShhShell
//
//  Created by neon443 on 08/06/2025.
//

import Foundation

protocol HostPr: Codable, Identifiable, Equatable {
	var id: UUID { get set }
	var address: String { get set }
	var port: Int { get set }
	var username: String { get set }
	var password: String { get set }
	var key: Data? { get set }
}

struct Host: HostPr {
	var id = UUID()
	var address: String = ""
	var port: Int
	var username: String
	var password: String
	var key: Data?
	
	init(
		address: String,
		port: Int = 22,
		username: String,
		password: String,
		hostkey: Data? = nil
	) {
		self.address = address
		self.port = port
		self.username = username
		self.password = password
		self.key = hostkey
	}
}

extension Host {
	static var blank: Host {
		Host(address: "", port: 22, username: "", password: "")
	}
	static var debug: Host {
		Host(address: "localhost", port: 22, username: "default", password: "")
	}
}
