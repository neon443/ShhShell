//
//  KeychainLayer.swift
//  ShhShell
//
//  Created by neon443 on 20/06/2025.
//

import Foundation
import CryptoKit

//https://developer.apple.com/documentation/cryptokit/storing-cryptokit-keys-in-the-keychain
protocol SecKeyConvertible: CustomStringConvertible {
	// cretes a ket from an x9.63 represenation
	init<Bytes>(x963Representation: Bytes) throws where Bytes: ContiguousBytes
	
	//an x9.63 representation of the key
	var x963Representation: Data { get }
}

protocol GenericPasswordConvertible {
	//creates key from generic rep
	init<D>(genericKeyRepresentation data: D) throws where D: ContiguousBytes
	
	//generic rep of key
	var genericKeyRepresentation: SymmetricKey { get }
}

extension Curve25519.KeyAgreement.PrivateKey: GenericPasswordConvertible {
	init<D>(genericKeyRepresentation data: D) throws where D: ContiguousBytes {
		try self.init(rawRepresentation: data)
	}
	
	var genericKeyRepresentation: SymmetricKey {
		self.rawRepresentation.withUnsafeBytes {
			SymmetricKey(data: $0)
		}
	}
}
extension Curve25519.Signing.PrivateKey: GenericPasswordConvertible {
	init<D>(genericKeyRepresentation data: D) throws where D: ContiguousBytes {
		try self.init(rawRepresentation: data)
	}
	
	var genericKeyRepresentation: SymmetricKey {
		self.rawRepresentation.withUnsafeBytes {
			SymmetricKey(data: $0)
		}
	}
}

enum KeyStoreError: Error {
	case KeyStoreError(String)
}

func storeKey<T: SecKeyConvertible>(_ key: T, label: String) throws {
	let attributes = [kSecAttrKeyType: kSecAttrKeyTypeECSECPrimeRandom,
					 kSecAttrKeyClass: kSecAttrKeyClassPrivate] as [String: Any]
	
	guard let secKey = SecKeyCreateWithData(
		key.x963Representation as CFData,
		attributes as CFDictionary,
		nil
	) else {
		throw KeyStoreError.KeyStoreError("unable to create SecKey represntation")
	}
	
	let query = [kSecClass: kSecClassKey,
  kSecAttrApplicationLabel: label,
		kSecAttrAccessible: kSecAttrAccessibleWhenUnlocked,
kSecUseDataProtectionKeychain: true,
			  kSecValueRef: secKey] as [String: Any]
	let status = SecItemAdd(query as CFDictionary, nil)
	guard status == errSecSuccess else {
		throw KeyStoreError.KeyStoreError("unable to sstore item \(status)")
	}
	
}


func retrieveKey(label: String) throws -> SecKey? {
	let query = [kSecClass: kSecClassKey,
  kSecAttrApplicationLabel: label,
		   kSecAttrKeyType: kSecAttrKeyTypeECSECPrimeRandom,
kSecUseDataProtectionKeychain: true,
			 kSecReturnRef: true] as [String: Any]
	
	var item: CFTypeRef?
	var secKey: SecKey
	switch SecItemCopyMatching(query as CFDictionary, &item) {
	case errSecSuccess: secKey = item as! SecKey
	case errSecItemNotFound: return nil
	case let status: throw KeyStoreError.KeyStoreError("keychain read failed")
	}
//	return secKey
	
	var error: Unmanaged<CFError>?
	guard let data = SecKeyCopyExternalRepresentation(secKey, &error) as Data? else {
		throw KeyStoreError.KeyStoreError(error.debugDescription)
	}
//	let key = try T(x963Representation: data)
	return nil
}
