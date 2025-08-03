//
//  Bundle.swift
//  ShhShell
//
//  Created by neon443 on 02/08/2025.
//

import Foundation
import SwiftUI

//app icon
extension Bundle {
	var appIconFilename: String? {
		guard let icons = infoDictionary?["CFBundleIcons"] as? [String: Any],
			  let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
			  let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
			  let iconFileName = iconFiles.last
		else { return nil }
		return iconFileName
	}
}

extension UIImage {
	var appIcon: Image {
//		let fallback = Image(uiImage: UIImage())
//		guard let filename = Bundle.main.appIconFilename else { return fallback }
//		guard let uiImage = UIImage(named: filename) else { return fallback }
//		return uiImage
		return Image("Icon")
	}
}

extension Bundle {
	var appVersion: String {
		let version = infoDictionary?["CFBundleShortVersionString"] as? String
		return version ?? "0.0"
	}
}

extension Bundle {
	var appBuild: String {
		let build = infoDictionary?["CFBundleVersion"] as? String
		return "(" + (build ?? "0") + ")"
	}
}
