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

/// The key information decoded from the JSON file
struct Keys: Decodable {
    var sigmaT: String
    var skT: String
    var pk_a: String
    
    init(sigmaT: String, skT: String, pk_a: String) {
        self.sigmaT = sigmaT
        self.skT = skT
        self.pk_a = pk_a
    }
}

extension Keys {
    enum CodingKeys: String, CodingKey {
        case sigmaT = "sigma_t"
        case skT = "sk_t"
        case pk_a = "pk_a"
    }
}

public struct ValidationResult: Codable {
    public let R: Data
    public let skT: Data
    public let hPKR: Data
}
