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

public enum LCLAuthError: Error {
    case incorrectHexValue
    case invalidFormatError
    case invalidCredential
    case invalidPublicKey
    case invalidSignature
    case corruptedCredential
    case invalidPrivateKey
    case keyGenerationFailed
    case messageSignFailed
}
