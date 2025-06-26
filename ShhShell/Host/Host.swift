//
//  Host.swift
//  ShhShell
//
//  Created by neon443 on 08/06/2025.
//

import Foundation
import SwiftUI

protocol HostPr: Codable, Identifiable, Equatable {
	var id: UUID { get set }
	var name: String { get set }
	var symbol: Symbol { get set }
	var label: String { get set }
	var address: String { get set }
	var port: Int { get set }
	var username: String { get set }
	var password: String { get set }
	var publicKey: Data? { get set }
	var privateKey: Data? { get set }
	var passphrase: String { get set }
	var key: String? { get set }
}

struct Host: HostPr {
	var id = UUID()
	var name: String
	var symbol: Symbol
	var label: String
	var address: String
	var port: Int
	var username: String
	var password: String
	var publicKey: Data?
	var privateKey: Data?
	var passphrase: String
	var key: String?
	
	init(
		name: String = "",
		symbol: Symbol = .genericServer,
		label: String = "",
		address: String,
		port: Int = 22,
		username: String = "",
		password: String = "",
		publicKey: Data? = nil,
		privateKey: Data? = nil,
		passphrase: String = "",
		hostkey: String? = nil
	) {
		self.name = name
		self.symbol = symbol
		self.label = label
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
			name: "name for localhost",
			label: "lo0",
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
