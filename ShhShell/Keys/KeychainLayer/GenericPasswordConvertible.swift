/*
 See the LICENSE.txt file for this sample’s licensing information.
 
 Abstract:
 The interface required for conversion to a generic password keychain item.
 */

import Foundation
import CryptoKit

/// The interface needed for SecKey conversion.
protocol GenericPasswordConvertible: CustomStringConvertible {
	/// Creates a key from a generic key representation.
	init<D>(genericKeyRepresentation data: D) throws where D: ContiguousBytes
	
	/// A generic representation of the key.
	var genericKeyRepresentation: SymmetricKey { get }
}

extension GenericPasswordConvertible {
	/// A string version of the key for visual inspection.
	/// IMPORTANT: Never log the actual key data.
	public var description: String {
		return self.genericKeyRepresentation.withUnsafeBytes { bytes in
			return "Key representation contains \(bytes.count) bytes."
		}
	}
}

// Declare that the Curve25519 keys are generic passord convertible.
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

// Ensure that SymmetricKey is generic password convertible.
extension SymmetricKey: GenericPasswordConvertible {
	init<D>(genericKeyRepresentation data: D) throws where D: ContiguousBytes {
		self.init(data: data)
	}
	
	var genericKeyRepresentation: SymmetricKey {
		self
	}
}

// Ensure that Secure Enclave keys are generic password convertible.
extension SecureEnclave.P256.KeyAgreement.PrivateKey: GenericPasswordConvertible {
	init<D>(genericKeyRepresentation data: D) throws where D: ContiguousBytes {
		try self.init(dataRepresentation: data.withUnsafeBytes { Data($0) })
	}
	
	var genericKeyRepresentation: SymmetricKey {
		return SymmetricKey(data: dataRepresentation)
	}
}

extension SecureEnclave.P256.Signing.PrivateKey: GenericPasswordConvertible {
	init<D>(genericKeyRepresentation data: D) throws where D: ContiguousBytes {
		try self.init(dataRepresentation: data.withUnsafeBytes { Data($0) })
	}
	
	var genericKeyRepresentation: SymmetricKey {
		return SymmetricKey(data: dataRepresentation)
	}
}
