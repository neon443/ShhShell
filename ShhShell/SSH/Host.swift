//
//  Host.swift
//  ShhShell
//
//  Created by neon443 on 08/06/2025.
//

import Foundation

protocol HostPr: Codable {
	var address: String { get set }
	var port: Int { get set }
	var username: String { get set }
	var password: String { get set }
	var key: Data? { get set }
}

struct Host: HostPr {
	var address: String = "address"
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

struct blankHost: HostPr {
	var address: String = ""
	var port: Int = 22
	var username: String = ""
	var password: String = ""
	var key: Data? = nil
}

struct debugHost: HostPr {
	var address: String = "localhost"
	var port: Int = 2222
	var username: String = "root"
	var password: String = "root"
	var key: Data? = nil
}
