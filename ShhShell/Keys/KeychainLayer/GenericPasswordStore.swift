/*
 See the LICENSE.txt file for this sample’s licensing information.
 
 Abstract:
 Methods for storing generic password convertible items in the keychain.
 */

import Foundation
import CryptoKit
import Security

struct GenericPasswordStore {
	
	/// Stores a CryptoKit key in the keychain as a generic password.
	func storeKey<T: GenericPasswordConvertible>(_ key: T, account: String) throws {
		
		// Treat the key data as a generic password.
		try key.genericKeyRepresentation.withUnsafeBytes { keyBytes in
			let cfd = Data(bytesNoCopy: UnsafeMutableRawPointer(mutating: keyBytes.baseAddress!), count: keyBytes.count, deallocator: .none)
			let query = [kSecClass: kSecClassGenericPassword,
				   kSecAttrAccount: account,
				kSecAttrAccessible: kSecAttrAccessibleWhenUnlocked,
	 kSecUseDataProtectionKeychain: true,
			kSecAttrSynchronizable: true,
					 kSecValueData: cfd] as [String: Any]
			
			// Add the key data.
			let status = SecItemAdd(query as CFDictionary, nil)
			guard status == errSecSuccess else {
				throw KeyStoreError("Unable to store item: \(status.message)")
			}
		}
		
	}
	
	/// Reads a CryptoKit key from the keychain as a generic password.
	func readKey<T: GenericPasswordConvertible>(account: String) throws -> T? {
		
		// Seek a generic password with the given account.
		let query = [kSecClass: kSecClassGenericPassword,
			   kSecAttrAccount: account,
 kSecUseDataProtectionKeychain: true,
				kSecReturnData: true,
		kSecAttrSynchronizable: true] as [String: Any]
		
		// Find and cast the result as data.
		var item: CFTypeRef?
		switch SecItemCopyMatching(query as CFDictionary, &item) {
		case errSecSuccess:
			guard let data = item as? Data else { return nil }
			return try T(genericKeyRepresentation: data)  // Convert back to a key.
		case errSecItemNotFound: return nil
		case let status: throw KeyStoreError("Keychain read failed: \(status.message)")
		}
	}
	
	/// Stores a key in the keychain and then reads it back.
	func roundTrip<T: GenericPasswordConvertible>(_ key: T) throws -> T {
		
		// An account name for the key in the keychain.
		let account = "com.example.genericpassword.key"
		
		// Start fresh.
		try deleteKey(account: account)
		
		// Store and read it back.
		try storeKey(key, account: account)
		guard let key: T = try readKey(account: account) else {
			throw KeyStoreError("Failed to locate stored key.")
		}
		return key
	}
	
	/// Removes any existing key with the given account.
	func deleteKey(account: String) throws {
		let query = [kSecClass: kSecClassGenericPassword,
 kSecUseDataProtectionKeychain: true,
		kSecAttrSynchronizable: kSecAttrSynchronizableAny,
			   kSecAttrAccount: account] as [String: Any]
		switch SecItemDelete(query as CFDictionary) {
		case errSecItemNotFound, errSecSuccess: break // Okay to ignore
		case let status:
			throw KeyStoreError("Unexpected deletion error: \(status.message)")
		}
	}
}
