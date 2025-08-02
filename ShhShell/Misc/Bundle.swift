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
	var iconFilename: String? {
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
		let fallback = Image(uiImage: UIImage())
		guard let filename = Bundle.main.iconFilename else { return fallback }
		guard let uiImage = UIImage(named: filename) else { return fallback }
		return Image(uiImage: uiImage)
	}
}
