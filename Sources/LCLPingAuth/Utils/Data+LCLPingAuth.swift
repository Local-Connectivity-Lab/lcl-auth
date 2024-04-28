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

let charA = Byte(UnicodeScalar("a").value)
let char0 = Byte(UnicodeScalar("0").value)

private func itoh(_ value: UInt8) -> UInt8 {
    return (value > 9) ? (charA + value - 10) : (char0 + value)
}

private func htoi(_ value: UInt8) throws -> UInt8 {
    switch value {
    case char0...char0 + 9:
        return value - char0
    case charA...charA + 5:
        return value - charA + 10
    default:
        throw LCLPingAuthError.incorrectHexValue
    }
}

extension Data {

    /// Initialize the `Data` from the hex string value
    init(hexString: String) throws {
        self.init()

        if hexString.count % 2 != 0 || hexString.count == 0 {
            throw LCLPingAuthError.invalidFormatError
        }

        let stringBytes: ByteArray = Array(hexString.lowercased().data(using: String.Encoding.utf8)!)

        for i in stride(from: stringBytes.startIndex, to: stringBytes.endIndex - 1, by: 2) {
            let char1 = stringBytes[i]
            let char2 = stringBytes[i + 1]

            try self.append(htoi(char1) << 4 + htoi(char2))
        }
    }
}

extension ByteArray {

    /// The  `Data` representation of the byte array
    var toData: Data {
        return Data(self)
    }
}

extension Data {

    /// The hex String representation of the given `Data`
    var hex: String {
        reduce("") { $0 + String(format: "%02hhx", $1) }
    }
}
