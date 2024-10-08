//
// This source file is part of the LCL open source project
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

public func deserialize<T: Decodable>(json: Data, as: T.Type) throws -> T? {
    return try JSONDecoder().decode(T.self, from: json)
}

public func validate(credential: Data) throws -> ValidationResult {
    guard let qrCode = try? deserialize(json: credential, as: Keys.self) else {
        throw LCLAuthError.invalidCredential
    }

    guard let pkA: Data = try? .init(hexString: qrCode.pk_a), let skT: Data = try? .init(hexString: qrCode.skT), let sigmaT: Data = try? .init(hexString: qrCode.sigmaT) else {
        throw LCLAuthError.invalidCredential
    }

    guard let pk_a = try? ECDSA.deserializePublicKey(raw: pkA) else {
        throw LCLAuthError.invalidPublicKey
    }

    guard let isValidSignature = try? ECDSA.verify(message: skT, signature: sigmaT, publicKey: pk_a) else {
        throw LCLAuthError.invalidSignature
    }

    if !isValidSignature {
        throw LCLAuthError.corruptedCredential
    }

    guard let sk_t = try? ECDSA.deserializePrivateKey(raw: skT) else {
        throw LCLAuthError.invalidPrivateKey
    }

    let pk_t = ECDSA.derivePublicKey(from: sk_t)

    let randomBytesResult = generateSecureRandomBytes(count: 16)
    let r: Data
    switch randomBytesResult {
    case .success(let data):
        r = data
    case .failure(let error):
        throw error
    }

    var outputData = Data()
    let h_pkr: Data

    outputData.append(pk_t.derRepresentation)
    outputData.append(r)

    h_pkr = digest(data: outputData, algorithm: .SHA256)
    outputData.removeAll()

    return ValidationResult(R: r, skT: skT, hPKR: h_pkr)
}
