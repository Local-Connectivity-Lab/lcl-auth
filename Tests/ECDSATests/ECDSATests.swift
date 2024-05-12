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

import XCTest
@testable import LCLAuth

final class ECDSATests: XCTestCase {

    func testECDSAPublicKeyConversion() throws {
        let hexFromServer = "308184020100301006072a8648ce3d020106052b8104000a046d306b0201010420798116c5c26ccfd95e4e13fdf4df9e46cf3629223b190da6c891d48e4de5da57a144034200044552ed599a2d855f59286447d687fbd1ed05793025a7994268f29baef5ca1e3432f9b1d48301a85e4bd8ed77e2c6f3e834f947540b144dbc5a71a548c046c9e2"

        let skBytes = try Data(hexString: hexFromServer)
        let sk = try ECDSA.deserializePrivateKey(raw: skBytes)
        let pk = ECDSA.derivePublicKey(from: sk)

        let message: ByteArray = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]
        let invalidMessage: ByteArray = [16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0]

        let signature = try ECDSA.sign(message: message.toData, privateKey: sk)
        let verified = try ECDSA.verify(message: message.toData, signature: signature, publicKey: pk)

        XCTAssertTrue(verified)

        let verifyFalse = try ECDSA.verify(message: invalidMessage.toData, signature: signature, publicKey: pk)
        XCTAssertFalse(verifyFalse)
    }

    func testECDSASignature() throws {
        let sigHex = "304502201d3ea6680d007b751d4e3c1d928a270a1e5ce06cd9b77a46a95542766bb50cb90221008666a33c7e3362a18795d5b96cc36541f8ca79d9190c4341642145d41feb6605"
        let messageHex = "308184020100301006072a8648ce3d020106052b8104000a046d306b0201010420798116c5c26ccfd95e4e13fdf4df9e46cf3629223b190da6c891d48e4de5da57a144034200044552ed599a2d855f59286447d687fbd1ed05793025a7994268f29baef5ca1e3432f9b1d48301a85e4bd8ed77e2c6f3e834f947540b144dbc5a71a548c046c9e2"
        let pkHex = "3056301006072a8648ce3d020106052b8104000a03420004da754f3ede85eec8b7dec3fda5dbdc35662f807f29433e2810743c889de15e1f5d4338453fc13c45e856287cc7849554f92aca832c66a094c7f7f231c50afebf"

        // The messageHex is the SK_t encoded which is signed by the server
        let skBytes = try Data(hexString: messageHex)
        XCTAssertEqual(skBytes.hex, messageHex)

        // Obtain the PK_A from the PK sent, this is SPKI Encoded since its directly obtained from the server.
        let pkABytes = try Data(hexString: pkHex)
        XCTAssertEqual(pkABytes.hex, pkHex)

        let pkA = try ECDSA.deserializePublicKey(raw: pkABytes)

        // Convert the Signature to a byte array
        let sigBytes = try Data(hexString: sigHex)
        XCTAssertEqual(sigBytes.hex, sigHex)

        let verifySignature = try ECDSA.verify(message: skBytes, signature: sigBytes, publicKey: pkA)
        XCTAssertTrue(verifySignature)
    }

}
