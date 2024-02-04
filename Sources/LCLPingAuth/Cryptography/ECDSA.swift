//
// This source file is part of the LCLPing open source project
//
// Copyright (c) 2021-2024 Local Connectivity Lab and the project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
// See CONTRIBUTORS for the list of project authors
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import LCLK1

/**
 The ECDSA (Elliptic Curve Digital Signature Algorithm) namespace that handles key serialization, deserialization, verification, and signing
 */
class ECDSA {

    /**
     Derive the corresponding public key from the ECDSA private key

     - Parameters:
        - from: the ECDSA private key as the base for public key

     - Returns: the ECDSA public key associated with the private key
     */
    public static func derivePublicKey(from sk: K1.ECDSA.PrivateKey) -> K1.ECDSA.PublicKey {
        return sk.publicKey
    }

    /**
     Deserialize the private key from the raw bytes

     - Parameters:
        - raw: the raw bytes of the private key that needs to be deserialized

     - Throws: error if the deserialization process failed

     - Returns: the ECDSA private key object backed by the raw bytes
     */
    public static func deserializePrivateKey(raw: Data) throws -> K1.ECDSA.PrivateKey {
        return try K1.ECDSA.PrivateKey(derRepresentation: raw)

    }

    /**
     Deserialize the public key from the raw bytes

     - Parameters:
        - raw: the raw bytes of the public key that needs to be deserialized

     - Throws: error if the deserialization process failed

     - Returns: the ECDSA public key object backed by the raw bytes
     */
    public static func deserializePublicKey(raw: Data) throws -> K1.ECDSA.PublicKey {
        return try K1.ECDSA.PublicKey(derRepresentation: raw)
    }

    /**
     Verify the signature is valid for the message using the public key

     - Parameters:
        - message: the message that will be validated against the signature
        - signature: the signature to be checked against the message and the public key
        - publicKey: the ECDSA public key used to verify the signature on the message

     - Throws: error if the verification failed

     - Returns: true if the signature if a valid signature for the message using the ECDSA public key; false otherwise
     */
    public static func verify(message: Data, signature: Data, publicKey: K1.ECDSA.PublicKey) throws -> Bool {
        let sig = try K1.ECDSA.Signature(derRepresentation: signature)
        return publicKey.isValidSignature(sig, unhashed: message, options: .init(malleabilityStrictness: .accepted))
    }

    /**
     Sign the message using the given private key

     - Parameters:
        - message: the data to be signed
        - privateKey: the ECDSA private key used to sign the message

     - Throws: error if the signing process failed

     - Returns: the signature in bytes signed by the private key on the message
     */
    public static func sign(message: Data, privateKey: K1.ECDSA.PrivateKey) throws -> Data {
        return try privateKey.signature(forUnhashed: message, options: .default).derRepresentation
    }
}


extension K1.ECDSA.Signature {
    /// The data representation of signature in bytes
    var toData: Data {
        var byteBuffer: ByteArray = []
        self.withUnsafeBytes {
            byteBuffer.append(contentsOf: $0)
        }

        return Data(byteBuffer)
    }
}

