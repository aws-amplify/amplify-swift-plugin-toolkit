//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest
@testable import Amplify
@testable import CognitoIdentityPoolOperations

class AWSCognitoIdentityPoolOperationsHelperTests: XCTestCase {

    func testCheckForInvalidPluginKeyAndVersionWithEmptyInput1() {
        do {
            try AWSCognitoIdentityPoolOperationsHelper.checkPluginKeyAndVersionAreValid(pluginKey: "",
                                                                                        pluginVersion: "")
            XCTFail("Should fail")
        } catch {
            guard let _ = error as? AuthError else {
                XCTFail("Should be of type AuthError")
                return
            }
        }
    }

    func testCheckForInvalidPluginKeyAndVersionWithEmptyInput2() {
        do {
            try AWSCognitoIdentityPoolOperationsHelper.checkPluginKeyAndVersionAreValid(pluginKey: "key",
                                                                                        pluginVersion: "")
            XCTFail("Should fail")
        } catch {
            guard let _ = error as? AuthError else {
                XCTFail("Should be of type AuthError")
                return
            }
        }
    }

    func testCheckForInvalidPluginKeyAndVersionWithEmptyInput3() {
        do {
            try AWSCognitoIdentityPoolOperationsHelper.checkPluginKeyAndVersionAreValid(pluginKey: "",
                                                                                        pluginVersion: "1")
            XCTFail("Should fail")
        } catch {
            guard let _ = error as? AuthError else {
                XCTFail("Should be of type AuthError")
                return
            }
        }
    }

    func testCheckForInvalidPluginKeyAndVersionWithLongInput1() {
        do {
            try AWSCognitoIdentityPoolOperationsHelper.checkPluginKeyAndVersionAreValid(pluginKey: "pluginKeyTooLongpluginKeyTooLongpluginKeyTooLong",
                                                                                        pluginVersion: "1.0.0")
            XCTFail("Should fail")
        } catch {
            guard let _ = error as? AuthError else {
                XCTFail("Should be of type AuthError")
                return
            }
        }
    }

    func testCheckForInvalidPluginKeyAndVersionWithLongInput2() {
        do {
            try AWSCognitoIdentityPoolOperationsHelper.checkPluginKeyAndVersionAreValid(pluginKey: "pluginKey",
                                                                                        pluginVersion: "1.00000.0000000000")
            XCTFail("Should fail")
        } catch {
            guard let _ = error as? AuthError else {
                XCTFail("Should be of type AuthError")
                return
            }
        }
    }

    func testCheckForInvalidPluginKeyAndVersionWithLongInput3() {
        do {
            try AWSCognitoIdentityPoolOperationsHelper.checkPluginKeyAndVersionAreValid(pluginKey: "pluginKeyTooLongpluginKeyTooLongpluginKeyTooLong",
                                                                                        pluginVersion: "1.00000.0000000000")
            XCTFail("Should fail")
        } catch {
            guard let _ = error as? AuthError else {
                XCTFail("Should be of type AuthError")
                return
            }
        }
    }

    func testCheckForInvalidPluginKeyAndVersionWithInvalidVersion1() {
        do {
            try AWSCognitoIdentityPoolOperationsHelper.checkPluginKeyAndVersionAreValid(pluginKey: "pluginKey",
                                                                                        pluginVersion: "pluginVersion")
            XCTFail("Should fail")
        } catch {
            guard let _ = error as? AuthError else {
                XCTFail("Should be of type AuthError")
                return
            }
        }
    }

    func testCheckForInvalidPluginKeyAndVersionWithInvalidVersion2() {
        do {
            try AWSCognitoIdentityPoolOperationsHelper.checkPluginKeyAndVersionAreValid(pluginKey: "pluginKey",
                                                                                        pluginVersion: "1-2-3")
            XCTFail("Should fail")
        } catch {
            guard let _ = error as? AuthError else {
                XCTFail("Should be of type AuthError")
                return
            }
        }
    }

    func testCheckForInvalidPluginKeyAndVersionWithInvalidKey() {
        do {
            try AWSCognitoIdentityPoolOperationsHelper.checkPluginKeyAndVersionAreValid(pluginKey: "pl12:;-",
                                                                                        pluginVersion: "1.0.0")
            XCTFail("Should fail")
        } catch {
            guard let _ = error as? AuthError else {
                XCTFail("Should be of type AuthError")
                return
            }
        }
    }

    func testCheckForValidPluginKeyAndVersion() {
        do {
            try AWSCognitoIdentityPoolOperationsHelper.checkPluginKeyAndVersionAreValid(pluginKey: "pluginKey",
                                                                                        pluginVersion: "1.0.0")
        } catch {
            XCTFail("Failed with error: \(error)")
        }
    }

}
