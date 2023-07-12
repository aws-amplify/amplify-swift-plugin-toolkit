//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import Amplify
import AWSPluginsCore
import AWSCognitoIdentity

struct AWSAuthCredentials: AWSTemporaryCredentials {

    /// The accessKeyId.  **Warning:** This value must never be exposed in plain text.
    public let accessKeyId: String

    /// The secretAccessKey. **Warning:** This value must never be exposed in plain text.
    public let secretAccessKey: String

    /// The sessionToken.  **Warning:** This value must never be exposed in plain text.
    public let sessionToken: String

    /// The expiration date of the credential. Credentials used after this date will result in authorization errors from the service.
    public let expiration: Date
}

extension AWSAuthCredentials: Codable { }

extension AWSAuthCredentials: Equatable { }

extension AWSAuthCredentials: CustomDebugDictionaryConvertible {

    /// A view of the credential with sensitive information redacted. This view is safe to log for debugging.
    var debugDictionary: [String: Any] {
        [
            "accessKey": accessKeyId.masked(interiorCount: 5),
            "secretAccessKey": secretAccessKey.masked(interiorCount: 5),
            "sessionToken": sessionToken.masked(interiorCount: 5),
            "expiration": expiration
        ]
    }
}

extension AWSAuthCredentials: CustomDebugStringConvertible {
    /// A view of the credential with sensitive information redacted. This view is safe to log for debugging.
    public var debugDescription: String {
        debugDictionary.debugDescription
    }
}

protocol CustomDebugDictionaryConvertible {
    var debugDictionary: [String: Any] { get }
}

extension AWSAuthCredentials {
    init(cognitoIdentityCredentials: CognitoIdentityClientTypes.Credentials) throws {
        guard
            let accessKeyId = cognitoIdentityCredentials.accessKeyId,
            let secretAccessKey = cognitoIdentityCredentials.secretKey,
            let sessionToken = cognitoIdentityCredentials.sessionToken,
            let expiration = cognitoIdentityCredentials.expiration
        else {
            throw AuthError.service(
                "Empty elements in Cognito Identity credentials",
                AmplifyErrorMessages.shouldNotHappenReportBugToAWS()
            )
        }

        self.init(
            accessKeyId: accessKeyId,
            secretAccessKey: secretAccessKey,
            sessionToken: sessionToken,
            expiration: expiration
        )
    }
}
