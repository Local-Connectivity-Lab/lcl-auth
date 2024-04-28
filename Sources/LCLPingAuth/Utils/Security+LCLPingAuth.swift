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
#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
import Security
#elseif os(Linux)
import Glibc
#else
#error("Unknown platform")
#endif
import Crypto

/**
 Generate secure random bytes with given size

 - Precondition: count has to be greater than 0
 - Parameters:
    - count: the number of bytes to generate
 - Returns: A `Result` type. When succeeded, the associated secure random data will be return; When failed, `LCLPingAuthError` will be returned
 */
public func generateSecureRandomBytes(count: Int) -> Result<Data, LCLPingAuthError> {
    var bytes: ByteArray = ByteArray(repeating: 0, count: count)

    #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
    let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
    if status != errSecSuccess {
        // failure
        return .failure(.keyGenerationFailed)
    }

    // success
    return .success(Data(bytes))
    #elseif os(Linux)
    let res = withUnsafeMutableBytes(of: &bytes) { buffer in
        return getentropy(buffer.baseAddress, count)
    }

    if res == -1 {
        // TODO: check errno for detailed error
        return .failure(.keyGenerationFailed)
    }

    return .success(Data(bytes))
    #endif
}

extension Digest {

    /// the bytes representation of the `Digest` data
    var bytes: [UInt8] { Array(makeIterator()) }

    /// the `Data` representation of the `Digest` data
    var data: Data { Data(bytes) }
}

/// SHA Hash Algorithms supported by the cryptography framework
public enum HashAlgorithm {
    case SHA256
    case SHA512
    case SHA384
}

/**
 Hash the given data into a digest using the given algorithm
 
 - Parameters:
    - data: the data to be hashed
    - algorithm: the `HashAlgorithm` that will be used to hash the data
 - Returns: the hashed message digest of the data with the given algorithm
 */
public func digest(data: Data, algorithm: HashAlgorithm) -> Data {
    switch algorithm {
    case .SHA256:
        return SHA256.hash(data: data).data
    case .SHA512:
        return SHA512.hash(data: data).data
    case .SHA384:
        return SHA384.hash(data: data).data
    }
}

/**
    Encrypt the plaintext using the given symmetric key

    - Parameters:
        - plainText: the plaintext data to be encrypted
        - key: the symmetric key that will be used for encryption
    
    - Returns: the encrypted data
*/
public func encrypt(plainText: Data, key: SymmetricKey) throws -> Data {
    let box = try AES.GCM.seal(plainText, using: key)
    return box.combined!
}

/**
    Decrypt the cipher data using the given symmetric key

    - Parameters:
        - cipher: the cipher text to be decrypted
        - key: the symmetric key that will be used for decryption
    - Returns: the decrypted data
*/
public func decrypt(cipher: Data, key: SymmetricKey) throws -> Data {
    let box = try AES.GCM.SealedBox(combined: cipher)
    return try AES.GCM.open(box, using: key)
}
