//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest
@testable import SecureStorage

class AWSCredentialStoreAttributesTests: XCTestCase {

    var awsCredentialStoreAttribute: AWSCredentialStoreAttributes!

    /// Given: an instance of `AWSCredentialStoreAttributes`
    /// When: `awsCredentialStoreAttribute.defaultGetQuery()` is invoked with a required service param
    /// Then: Validate if the attributes contain the correct get query params
    ///     - AttributeService
    ///     - Class
    func testDefaultGetQuery() {
        awsCredentialStoreAttribute = AWSCredentialStoreAttributes(service: "someService")

        let defaultGetAttributes = awsCredentialStoreAttribute.defaultGetQuery()
        XCTAssertEqual(defaultGetAttributes[AWSCredentialStore.Constants.AttributeService] as? String, "someService")
        XCTAssertEqual(defaultGetAttributes[AWSCredentialStore.Constants.Class] as? String, AWSCredentialStore.Constants.ClassGenericPassword)
        XCTAssertNil(defaultGetAttributes[AWSCredentialStore.Constants.AttributeAccessGroup] as? String)
        XCTAssertNil(defaultGetAttributes[AWSCredentialStore.Constants.AttributeAccessible] as? String)
        XCTAssertNil(defaultGetAttributes[AWSCredentialStore.Constants.UseDataProtectionKeyChain] as? String)
    }

    /// Given: an instance of `AWSCredentialStoreAttributes`
    /// When: `awsCredentialStoreAttribute.defaultGetQuery()` is invoked with a required service param and access group
    /// Then: Validate if the attributes contain the correct get query params
    ///     - AttributeService
    ///     - Class
    ///     - AttributeAccessGroup
    func testDefaultGetQueryWithAccessGroup() {
        awsCredentialStoreAttribute = AWSCredentialStoreAttributes(service: "someService", accessGroup: "someAccessGroup")

        let defaultGetAttributes = awsCredentialStoreAttribute.defaultGetQuery()
        XCTAssertEqual(defaultGetAttributes[AWSCredentialStore.Constants.AttributeService] as? String, "someService")
        XCTAssertEqual(defaultGetAttributes[AWSCredentialStore.Constants.Class] as? String, AWSCredentialStore.Constants.ClassGenericPassword)
        XCTAssertEqual(defaultGetAttributes[AWSCredentialStore.Constants.AttributeAccessGroup] as? String, "someAccessGroup")
        XCTAssertNil(defaultGetAttributes[AWSCredentialStore.Constants.AttributeAccessible] as? String)
        XCTAssertNil(defaultGetAttributes[AWSCredentialStore.Constants.UseDataProtectionKeyChain] as? String)
    }

    /// Given: an instance of `AWSCredentialStoreAttributes`
    /// When: `awsCredentialStoreAttribute.defaultSetQuery()` is invoked with a required service param and access group
    /// Then: Validate if the attributes contain the correct get query params
    ///     - AttributeService
    ///     - Class
    ///     - AttributeAccessGroup
    ///     - AttributeAccessible
    ///     - UseDataProtectionKeyChain
    func testDefaultSetQueryWithAccessGroup() {
        awsCredentialStoreAttribute = AWSCredentialStoreAttributes(service: "someService", accessGroup: "someAccessGroup")

        let defaultGetAttributes = awsCredentialStoreAttribute.defaultSetQuery()
        XCTAssertEqual(defaultGetAttributes[AWSCredentialStore.Constants.AttributeService] as? String, "someService")
        XCTAssertEqual(defaultGetAttributes[AWSCredentialStore.Constants.Class] as? String, AWSCredentialStore.Constants.ClassGenericPassword)
        XCTAssertEqual(defaultGetAttributes[AWSCredentialStore.Constants.AttributeAccessGroup] as? String, "someAccessGroup")
        XCTAssertEqual(defaultGetAttributes[AWSCredentialStore.Constants.AttributeAccessible] as? String, AWSCredentialStore.Constants.AttributeAccessibleAfterFirstUnlockThisDeviceOnly)
        XCTAssertEqual(defaultGetAttributes[AWSCredentialStore.Constants.UseDataProtectionKeyChain] as? Bool, true)
    }

    override func tearDown() {
        awsCredentialStoreAttribute = nil
    }
}
