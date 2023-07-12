//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import Security
import Amplify

public struct AWSCredentialStoreError: Equatable {

    let code: UInt8
    public var errorDescription: ErrorDescription
    public var recoverySuggestion: RecoverySuggestion
    public var underlyingError: Error?

    public static func == (lhs: AWSCredentialStoreError,
                           rhs: AWSCredentialStoreError) -> Bool {
        return lhs.code == rhs.code
    }

    init(_ code: UInt8,
         errorDescription: ErrorDescription = "An unknown error occurred",
         recoverySuggestion: RecoverySuggestion = AmplifyErrorMessages.shouldNotHappenReportBugToAWS(),
         underlyingError: Error? = nil) {
        self.code = code
        self.errorDescription = errorDescription
        self.recoverySuggestion = recoverySuggestion
        self.underlyingError = underlyingError
    }

    public static let configuration: Self = .init(0)
    public static let unknown: Self = .init(1)
    public static let conversionError: Self = .init(2)
    public static let codingError: Self = .init(3)
    public static let itemNotFound: Self = .init(4)
    public static let securityError: Self = .init(5)

    public static func configuration(message: String) -> Self {
        .init(0,
              errorDescription: message,
              recoverySuggestion: AmplifyErrorMessages.shouldNotHappenReportBugToAWS())
    }

    public static func unknown(errorDescription: ErrorDescription,
                               error: Error? = nil) -> Self {
        .init(1,
              errorDescription: "Unexpected error occurred with message: \(errorDescription)",
              recoverySuggestion: AmplifyErrorMessages.shouldNotHappenReportBugToAWS(),
              underlyingError: error)
    }

    public static func conversionError(errorDescription: ErrorDescription,
                                       error: Error? = nil) -> Self {
        .init(2,
              errorDescription: errorDescription,
              recoverySuggestion: AmplifyErrorMessages.shouldNotHappenReportBugToAWS(),
              underlyingError: error)
    }

    public static func codingError(errorDescription: ErrorDescription,
                                   error: Error? = nil) -> Self {
        .init(3,
              errorDescription: errorDescription,
              recoverySuggestion: AmplifyErrorMessages.shouldNotHappenReportBugToAWS(),
              underlyingError: error)
    }

    public static func itemNotFound(errorDescription: ErrorDescription = "Unable to find the keychain item") -> Self {
        .init(4,
              errorDescription: errorDescription,
              recoverySuggestion: AmplifyErrorMessages.shouldNotHappenReportBugToAWS())
    }

    public static func securityError(osStatus: OSStatus) -> Self {
        .init(5,
              errorDescription: "Keychain error occurred with status: \(osStatus)",
              recoverySuggestion: AmplifyErrorMessages.shouldNotHappenReportBugToAWS())
    }
}

extension AWSCredentialStoreError: AmplifyError {

    public init(
        errorDescription: ErrorDescription = "An unknown error occurred",
        recoverySuggestion: RecoverySuggestion = AmplifyErrorMessages.shouldNotHappenReportBugToAWS(),
        error: Error
    ) {
        self.init(1,
        errorDescription: errorDescription,
        recoverySuggestion: recoverySuggestion,
        underlyingError: error)
    }

}
