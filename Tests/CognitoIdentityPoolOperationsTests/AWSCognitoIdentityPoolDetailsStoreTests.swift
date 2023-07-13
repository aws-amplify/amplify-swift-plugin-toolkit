//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest
@testable import Amplify
@testable import SecureStorage
@testable import CognitoIdentityPoolOperations

class AWSCognitoIdentityPoolDetailsStoreTests: XCTestCase {

    var awsCognitoIdentityPoolsDetailsStore: AWSCognitoIdentityPoolDetailsStore!
    var config: AWSCognitoIdentityPoolConfiguration!
    var awsCredentialStore: MockAWSCredentialStore!
    let keySuffix = "keySuffix"

    override func setUp() {
        self.config = AWSCognitoIdentityPoolConfiguration(region: "region",
                                                          identityPoolId: "poolId")
        self.awsCredentialStore = MockAWSCredentialStore()
        self.awsCognitoIdentityPoolsDetailsStore = AWSCognitoIdentityPoolDetailsStore(
            identityPoolConfiguration: self.config,
            credentialStoreBehavior: self.awsCredentialStore,
            keySuffix: self.keySuffix)
    }

    /// Given: an instance of `AWSCognitoIdentityPoolDetailsStore`
    /// When: `saveAWSCognitoIdentityPoolDetails()` is invoked
    /// Then: putString() on the credentialstore should be called once
    ///       putData() on the credentialstore should be called twice
    func testSaveAWSCognitoIdentityPoolDetails() throws {
        let credentials = AWSAuthCredentials(accessKeyId: "accessKeyId",
                                             secretAccessKey: "secretAccessKey",
                                             sessionToken: "sessionToken",
                                             expiration: Date.distantPast)
        try awsCognitoIdentityPoolsDetailsStore.saveAWSCognitoIdentityPoolDetails(
            credentials,
            "identityId",
            [])
        XCTAssertEqual(awsCredentialStore.putStringCallCount, 1)
        XCTAssertEqual(awsCredentialStore.putDataCallCount, 2)
    }

    /// Given: an instance of `AWSCognitoIdentityPoolDetailsStore`
    /// When: `retrieveAWSCognitoIdentityPoolDetails()` is invoked
    /// Then: getString() on the credentialstore should be called once
    ///       getData() on the credentialstore should be called twice
    func testRetrieveAWSCognitoIdentityPoolDetails() throws {
        let credentials = AWSAuthCredentials(accessKeyId: "accessKeyId",
                                             secretAccessKey: "secretAccessKey",
                                             sessionToken: "sessionToken",
                                             expiration: Date.distantPast)
        try awsCognitoIdentityPoolsDetailsStore.saveAWSCognitoIdentityPoolDetails(
            credentials,
            "identityId",
            [])

        _ = try awsCognitoIdentityPoolsDetailsStore.retrieveAWSCognitoIdentityPoolDetails()
        XCTAssertEqual(awsCredentialStore.getStringCallCount, 1)
        XCTAssertEqual(awsCredentialStore.getDataCallCount, 2)
    }

    /// Given: an instance of `AWSCognitoIdentityPoolDetailsStore`
    /// When: `retrieveAWSCognitoIdentityPoolDetails()` is invoked
    /// Then: removeAll() on the credentialstore should be called
    func testDeleteAWSCognitoIdentityPoolDetails() throws {
        _ = try awsCognitoIdentityPoolsDetailsStore.deleteAWSCognitoIdentityPoolDetails()
        XCTAssertTrue(awsCredentialStore.removeAllCalled)
    }
}
