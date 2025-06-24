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
	var publicKey: Data? { get set }
	var privateKey: Data? { get set }
	var passphrase: String { get set }
	var key: Data? { get set }
}

struct Host: HostPr {
	var id = UUID()
	var address: String = ""
	var port: Int
	var username: String
	var password: String
	var publicKey: Data?
	var privateKey: Data?
	var passphrase: String = ""
	var key: Data?
	
	init(
		address: String,
		port: Int = 22,
		username: String = "",
		password: String = "",
		publicKey: Data? = nil,
		privateKey: Data? = nil,
		passphrase: String = "",
		hostkey: Data? = nil
	) {
		self.address = address
		self.port = port
		self.username = username
		self.password = password
		self.publicKey = publicKey
		self.privateKey = privateKey
		self.passphrase = passphrase
		self.key = hostkey
	}
}

extension Host {
	static var blank: Host {
		Host(address: "")
	}
	static var debug: Host {
		Host(
			address: "localhost",
			port: 22,
			username: "neon443",
			password: "password",
			publicKey: nil,
			privateKey: nil,
			passphrase: "",
			hostkey: nil
		)
	}
}
