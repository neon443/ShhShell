//
//  ShellHandler.swift
//  ShhShell
//
//  Created by neon443 on 05/06/2025.
//

import Foundation
import NMSSH

class ShellHandler: NSObject, NMSSHChannelDelegate {
	func channel(_ channel: NMSSHChannel, didReadData message: String) {
		print(channel)
		print(message)
	}
	
	func channel(_ channel: NMSSHChannel, didReadError error: String) {
		print(error)
		print("error")
	}
	
	func channelShellDidClose(_ channel: NMSSHChannel) {
		print(channel)
		print("closed channel")
	}
}
