//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest
@testable import Amplify
@testable import CognitoIdentityPoolOperations
@testable import SecureStorage

class AWSCognitoIdentityPoolOperationsTests: XCTestCase {

    var awsCognitoIdentityPoolOperations: AWSCognitoIdentityPoolOperationsBehavior!

    var credentialStore: MockAWSCredentialStore!

    var poolDetailsStore: AWSCognitoIdentityPoolDetailsStore!

    var cognitoIdentityClient: MockCognitoIdentityClient!

    let region = "us-east-1"

    let identityPoolId = "us-east-1:xxxx:xxxx:xxxx:xxxx"

    let pluginSuffix = "mockSuffix"

    let pluginVersion = "1.0.0"

    override func setUpWithError() throws {
        let config = AWSCognitoIdentityPoolConfiguration(region: region,
                                                         identityPoolId: identityPoolId)
        credentialStore = MockAWSCredentialStore()
        poolDetailsStore = AWSCognitoIdentityPoolDetailsStore(identityPoolConfiguration: config,
                                                                  credentialStoreBehavior: credentialStore,
                                                                  keySuffix: pluginSuffix)
        cognitoIdentityClient = MockCognitoIdentityClient(config: config)
        awsCognitoIdentityPoolOperations = try AWSCognitoIdentityPoolOperations(
            cognitoIdentityPoolConfiguration: config,
            cognitoIdentityClient: cognitoIdentityClient,
            cognitoIdentityPoolDetailsStoreBehavior: poolDetailsStore,
            pluginKey: pluginSuffix,
            pluginVersion: pluginVersion)
    }

    /// - Given: `AWSCognitoIdentityPoolOperations` configured with a mock cognito
    ///           identity client and mock credentials store
    /// - When: fetchAWSCognitoIdentityPoolDetails() is called first time
    /// - Then: getId() and getCredentialsForIdentity() is called on cognito identity client
    func testGetIdAndGetCredentialsForIdentityCalledInitiallly() async {
        let loginProvider = LoginProvider(providerName: "mockProvider",
                                          providerUserIdentifier: "mockProviderId")
        let result = await awsCognitoIdentityPoolOperations.fetchAWSCognitoIdentityPoolDetails(
            logins: [loginProvider],
            forceRefresh: false)
        XCTAssertEqual(cognitoIdentityClient.getIdCallCount, 1)
        XCTAssertEqual(cognitoIdentityClient.getCredentialsForIdentityCallCount, 1)
        XCTAssertEqual(try result.identityIdResult.get(), cognitoIdentityClient.mockIdentityId)
        XCTAssertEqual(try result.awsCredentialsResult.get().accessKeyId, cognitoIdentityClient.mockAccessKeyId)
        XCTAssertEqual(try result.awsCredentialsResult.get().expiration, cognitoIdentityClient.mockExpiration)
        XCTAssertEqual(try result.awsCredentialsResult.get().secretAccessKey, cognitoIdentityClient.mockSecretKey)
        XCTAssertEqual(try result.awsCredentialsResult.get().sessionToken, cognitoIdentityClient.mockSessionToken)
    }

    /// - Given: `AWSCognitoIdentityPoolOperations` configured with a mock cognito
    ///           identity client and mock credentials store
    /// - When: fetchAWSCognitoIdentityPoolDetails() is called with forceRefresh true
    /// - Then: getId() and getCredentialsForIdentity() is called on cognito identity client
    func testGetIdAndGetCredentialsForIdentityCalledWithInitialForceRefresh() async {
        let loginProvider = LoginProvider(providerName: "mockProvider",
                                          providerUserIdentifier: "mockProviderId")
        let result = await awsCognitoIdentityPoolOperations.fetchAWSCognitoIdentityPoolDetails(
            logins: [loginProvider],
            forceRefresh: true)
        XCTAssertEqual(cognitoIdentityClient.getIdCallCount, 1)
        XCTAssertEqual(cognitoIdentityClient.getCredentialsForIdentityCallCount, 1)
        XCTAssertEqual(try result.identityIdResult.get(), cognitoIdentityClient.mockIdentityId)
        XCTAssertEqual(try result.awsCredentialsResult.get().accessKeyId, cognitoIdentityClient.mockAccessKeyId)
        XCTAssertEqual(try result.awsCredentialsResult.get().expiration, cognitoIdentityClient.mockExpiration)
        XCTAssertEqual(try result.awsCredentialsResult.get().secretAccessKey, cognitoIdentityClient.mockSecretKey)
        XCTAssertEqual(try result.awsCredentialsResult.get().sessionToken, cognitoIdentityClient.mockSessionToken)
    }

    /// - Given: `AWSCognitoIdentityPoolOperations` configured with a mock cognito
    ///           identity client and mock credentials store
    /// - When: fetchAWSCognitoIdentityPoolDetails() is called twice with same provider
    ///         credentials still valid
    /// - Then: getId() and getCredentialsForIdentity() is called only once
    func testGetIdAndGetCredentialsForIdentityCalled() async {
        let loginProvider = LoginProvider(providerName: "mockProvider",
                                          providerUserIdentifier: "mockProviderId")
        var result = await awsCognitoIdentityPoolOperations.fetchAWSCognitoIdentityPoolDetails(
            logins: [loginProvider],
            forceRefresh: false)
        XCTAssertEqual(cognitoIdentityClient.getIdCallCount, 1)
        XCTAssertEqual(cognitoIdentityClient.getCredentialsForIdentityCallCount, 1)
        XCTAssertEqual(try result.identityIdResult.get(), cognitoIdentityClient.mockIdentityId)
        XCTAssertEqual(try result.awsCredentialsResult.get().accessKeyId, cognitoIdentityClient.mockAccessKeyId)
        XCTAssertEqual(try result.awsCredentialsResult.get().expiration, cognitoIdentityClient.mockExpiration)
        XCTAssertEqual(try result.awsCredentialsResult.get().secretAccessKey, cognitoIdentityClient.mockSecretKey)
        XCTAssertEqual(try result.awsCredentialsResult.get().sessionToken, cognitoIdentityClient.mockSessionToken)

        result = await awsCognitoIdentityPoolOperations.fetchAWSCognitoIdentityPoolDetails(
            logins: [loginProvider],
            forceRefresh: false)
        XCTAssertEqual(cognitoIdentityClient.getIdCallCount, 1)
        XCTAssertEqual(cognitoIdentityClient.getCredentialsForIdentityCallCount, 1)
        XCTAssertEqual(try result.identityIdResult.get(), cognitoIdentityClient.mockIdentityId)
        XCTAssertEqual(try result.awsCredentialsResult.get().accessKeyId, cognitoIdentityClient.mockAccessKeyId)
        XCTAssertEqual(try result.awsCredentialsResult.get().expiration, cognitoIdentityClient.mockExpiration)
        XCTAssertEqual(try result.awsCredentialsResult.get().secretAccessKey, cognitoIdentityClient.mockSecretKey)
        XCTAssertEqual(try result.awsCredentialsResult.get().sessionToken, cognitoIdentityClient.mockSessionToken)
    }

    /// - Given: `AWSCognitoIdentityPoolOperations` configured with a mock cognito
    ///           identity client and mock credentials store
    /// - When: fetchAWSCognitoIdentityPoolDetails() is called twice with same provider, once with
    ///         forceRefresh false and then forceRefresh as true
    /// - Then: getId() is called once and getCredentialsForIdentity() is called twice
    func testGetIdAndGetCredentialsForIdentityCalledWithForceRefresh() async {
        let loginProvider = LoginProvider(providerName: "mockProvider",
                                          providerUserIdentifier: "mockProviderId")
        var result = await awsCognitoIdentityPoolOperations.fetchAWSCognitoIdentityPoolDetails(
            logins: [loginProvider],
            forceRefresh: false)
        XCTAssertEqual(cognitoIdentityClient.getIdCallCount, 1)
        XCTAssertEqual(cognitoIdentityClient.getCredentialsForIdentityCallCount, 1)
        XCTAssertEqual(try result.identityIdResult.get(), cognitoIdentityClient.mockIdentityId)
        XCTAssertEqual(try result.awsCredentialsResult.get().accessKeyId, cognitoIdentityClient.mockAccessKeyId)
        XCTAssertEqual(try result.awsCredentialsResult.get().expiration, cognitoIdentityClient.mockExpiration)
        XCTAssertEqual(try result.awsCredentialsResult.get().secretAccessKey, cognitoIdentityClient.mockSecretKey)
        XCTAssertEqual(try result.awsCredentialsResult.get().sessionToken, cognitoIdentityClient.mockSessionToken)

        result = await awsCognitoIdentityPoolOperations.fetchAWSCognitoIdentityPoolDetails(
            logins: [loginProvider],
            forceRefresh: true)
        XCTAssertEqual(cognitoIdentityClient.getIdCallCount, 1)
        XCTAssertEqual(cognitoIdentityClient.getCredentialsForIdentityCallCount, 2)
        XCTAssertEqual(try result.identityIdResult.get(), cognitoIdentityClient.mockIdentityId)
        XCTAssertEqual(try result.awsCredentialsResult.get().accessKeyId, cognitoIdentityClient.mockAccessKeyId)
        XCTAssertEqual(try result.awsCredentialsResult.get().expiration, cognitoIdentityClient.mockExpiration)
        XCTAssertEqual(try result.awsCredentialsResult.get().secretAccessKey, cognitoIdentityClient.mockSecretKey)
        XCTAssertEqual(try result.awsCredentialsResult.get().sessionToken, cognitoIdentityClient.mockSessionToken)
    }

    /// - Given: `AWSCognitoIdentityPoolOperations` configured with a mock cognito
    ///           identity client and mock credentials store
    /// - When: fetchAWSCognitoIdentityPoolDetails() is called twice with same provider,
    ///         in the second call credentials are expired
    /// - Then: getId() is called once and getCredentialsForIdentity() is called twice
    func testGetIdAndGetCredentialsForIdentityWhenCredentialsExpired() async {
        cognitoIdentityClient.mockExpiration = Date.distantPast
        let loginProvider = LoginProvider(providerName: "mockProvider",
                                          providerUserIdentifier: "mockProviderId")
        var result = await awsCognitoIdentityPoolOperations.fetchAWSCognitoIdentityPoolDetails(
            logins: [loginProvider],
            forceRefresh: false)
        XCTAssertEqual(cognitoIdentityClient.getIdCallCount, 1)
        XCTAssertEqual(cognitoIdentityClient.getCredentialsForIdentityCallCount, 1)
        XCTAssertEqual(try result.identityIdResult.get(), cognitoIdentityClient.mockIdentityId)
        XCTAssertEqual(try result.awsCredentialsResult.get().accessKeyId, cognitoIdentityClient.mockAccessKeyId)
        XCTAssertEqual(try result.awsCredentialsResult.get().expiration, cognitoIdentityClient.mockExpiration)
        XCTAssertEqual(try result.awsCredentialsResult.get().secretAccessKey, cognitoIdentityClient.mockSecretKey)
        XCTAssertEqual(try result.awsCredentialsResult.get().sessionToken, cognitoIdentityClient.mockSessionToken)

        cognitoIdentityClient.mockExpiration = Date.distantFuture
        result = await awsCognitoIdentityPoolOperations.fetchAWSCognitoIdentityPoolDetails(
            logins: [loginProvider],
            forceRefresh: false)
        XCTAssertEqual(cognitoIdentityClient.getIdCallCount, 1)
        XCTAssertEqual(cognitoIdentityClient.getCredentialsForIdentityCallCount, 2)
        XCTAssertEqual(try result.identityIdResult.get(), cognitoIdentityClient.mockIdentityId)
        XCTAssertEqual(try result.awsCredentialsResult.get().accessKeyId, cognitoIdentityClient.mockAccessKeyId)
        XCTAssertEqual(try result.awsCredentialsResult.get().expiration, cognitoIdentityClient.mockExpiration)
        XCTAssertEqual(try result.awsCredentialsResult.get().secretAccessKey, cognitoIdentityClient.mockSecretKey)
        XCTAssertEqual(try result.awsCredentialsResult.get().sessionToken, cognitoIdentityClient.mockSessionToken)
    }

    /// - Given: `AWSCognitoIdentityPoolOperations` configured with a mock cognito
    ///           identity client and mock credentials store
    /// - When: fetchAWSCognitoIdentityPoolDetails() is called twice with different providers
    /// - Then: getId() is called once and getCredentialsForIdentity() is called twice
    func testGetIdAndGetCredentialsForIdentityCalledWithDifferentProvider() async {
        let loginProvider1 = LoginProvider(providerName: "mockProvider1",
                                          providerUserIdentifier: "mockProviderId1")
        var result = await awsCognitoIdentityPoolOperations.fetchAWSCognitoIdentityPoolDetails(
            logins: [loginProvider1],
            forceRefresh: false)
        XCTAssertEqual(cognitoIdentityClient.getIdCallCount, 1)
        XCTAssertEqual(cognitoIdentityClient.getCredentialsForIdentityCallCount, 1)
        XCTAssertEqual(try result.identityIdResult.get(), cognitoIdentityClient.mockIdentityId)
        XCTAssertEqual(try result.awsCredentialsResult.get().accessKeyId, cognitoIdentityClient.mockAccessKeyId)
        XCTAssertEqual(try result.awsCredentialsResult.get().expiration, cognitoIdentityClient.mockExpiration)
        XCTAssertEqual(try result.awsCredentialsResult.get().secretAccessKey, cognitoIdentityClient.mockSecretKey)
        XCTAssertEqual(try result.awsCredentialsResult.get().sessionToken, cognitoIdentityClient.mockSessionToken)

        let loginProvider2 = LoginProvider(providerName: "mockProvider2",
                                          providerUserIdentifier: "mockProviderId2")
        result = await awsCognitoIdentityPoolOperations.fetchAWSCognitoIdentityPoolDetails(
            logins: [loginProvider2],
            forceRefresh: false)
        XCTAssertEqual(cognitoIdentityClient.getIdCallCount, 1)
        XCTAssertEqual(cognitoIdentityClient.getCredentialsForIdentityCallCount, 2)
        XCTAssertEqual(try result.identityIdResult.get(), cognitoIdentityClient.mockIdentityId)
        XCTAssertEqual(try result.awsCredentialsResult.get().accessKeyId, cognitoIdentityClient.mockAccessKeyId)
        XCTAssertEqual(try result.awsCredentialsResult.get().expiration, cognitoIdentityClient.mockExpiration)
        XCTAssertEqual(try result.awsCredentialsResult.get().secretAccessKey, cognitoIdentityClient.mockSecretKey)
        XCTAssertEqual(try result.awsCredentialsResult.get().sessionToken, cognitoIdentityClient.mockSessionToken)
    }

    /// - Given: `AWSCognitoIdentityPoolOperations` configured with a mock cognito
    ///           identity client and mock credentials store
    /// - When: fetchAWSCognitoIdentityPoolDetails() is called and then clearCredentials is called
    /// - Then: Credentials should be cleared
    func testClearCredentialsSuccess() async {
        let loginProvider = LoginProvider(providerName: "mockProvider",
                                          providerUserIdentifier: "mockProviderId")
        let result = await awsCognitoIdentityPoolOperations.fetchAWSCognitoIdentityPoolDetails(
            logins: [loginProvider],
            forceRefresh: false)
        XCTAssertEqual(cognitoIdentityClient.getIdCallCount, 1)
        XCTAssertEqual(cognitoIdentityClient.getCredentialsForIdentityCallCount, 1)
        XCTAssertEqual(try result.identityIdResult.get(), cognitoIdentityClient.mockIdentityId)
        XCTAssertEqual(try result.awsCredentialsResult.get().accessKeyId, cognitoIdentityClient.mockAccessKeyId)
        XCTAssertEqual(try result.awsCredentialsResult.get().expiration, cognitoIdentityClient.mockExpiration)
        XCTAssertEqual(try result.awsCredentialsResult.get().secretAccessKey, cognitoIdentityClient.mockSecretKey)
        XCTAssertEqual(try result.awsCredentialsResult.get().sessionToken, cognitoIdentityClient.mockSessionToken)

        do {
            try await awsCognitoIdentityPoolOperations.clearCredentials()
            XCTAssertTrue(credentialStore.removeAllCalled)

        } catch {
            XCTFail("Failed with error: \(error)")
        }

        do {
            _ = try poolDetailsStore.retrieveAWSCognitoIdentityPoolDetails()
            XCTFail("Should fail as credentials are not present")
        } catch {
            guard let _ = error as? AWSCredentialStoreError else {
                XCTFail("Should be of type AWSCredentialStoreError")
                return
            }
        }
    }

    /// - Given: `AWSCognitoIdentityPoolOperations` configured with a mock cognito
    ///           identity client and mock credentials store
    /// - When: fetchAWSCognitoIdentityPoolDetails() and clearCredentials() are called from multiple tasks
    /// - Then: The results are correctly observed
    func testMultipleInvocationsOfFetchAndClear() async throws {
        let loginProvider = LoginProvider(providerName: "mockProvider",
                                          providerUserIdentifier: "mockProviderId")

        let fetchExpectation1 = expectation(description: "Credentials are fetched1")
        let clearExpectation1 = expectation(description: "Credentials are cleared1")
        let fetchExpectation2 = expectation(description: "Credentials are fetched2")
        let clearExpectation2 = expectation(description: "Credentials are cleared2")
        let fetchExpectation3 = expectation(description: "Credentials are fetched3")
        let clearExpectation3 = expectation(description: "Credentials are cleared3")
        let fetchExpectation4 = expectation(description: "Credentials are fetched4")
        let clearExpectation4 = expectation(description: "Credentials are cleared4")
        let fetchExpectation5 = expectation(description: "Credentials are fetched5")
        let clearExpectation5 = expectation(description: "Credentials are cleared5")

        let taskQueue = TaskQueue<Void>()
        try await taskQueue.sync {
            await self.executeFetchTask(logins: [loginProvider], expectation: fetchExpectation1)
        }

        let delayInNanoSeconds: UInt64 = 1
        try await Task.sleep(nanoseconds: delayInNanoSeconds)
        try await taskQueue.sync {
            await self.executeClearTask(expectation: clearExpectation1)
        }

        try await Task.sleep(nanoseconds: delayInNanoSeconds)
        try await taskQueue.sync {
            await self.executeFetchTask(logins: [loginProvider], expectation: fetchExpectation2)
        }

        try await Task.sleep(nanoseconds: delayInNanoSeconds)
        try await taskQueue.sync {
            await self.executeClearTask(expectation: clearExpectation2)
        }

        try await Task.sleep(nanoseconds: delayInNanoSeconds)
        try await taskQueue.sync {
            await self.executeFetchTask(logins: [loginProvider], expectation: fetchExpectation3)
        }

        try await Task.sleep(nanoseconds: delayInNanoSeconds)
        try await taskQueue.sync {
            await self.executeClearTask(expectation: clearExpectation3)
        }

        try await Task.sleep(nanoseconds: delayInNanoSeconds)
        try await taskQueue.sync {
            await self.executeFetchTask(logins: [loginProvider], expectation: fetchExpectation4)
        }

        try await Task.sleep(nanoseconds: delayInNanoSeconds)
        try await taskQueue.sync {
            await self.executeClearTask(expectation: clearExpectation4)
        }

        try await Task.sleep(nanoseconds: delayInNanoSeconds)
        try await taskQueue.sync {
            await self.executeFetchTask(logins: [loginProvider], expectation: fetchExpectation5)
        }

        try await Task.sleep(nanoseconds: delayInNanoSeconds)
        try await taskQueue.sync {
            await self.executeClearTask(expectation: clearExpectation5)
        }

        await fulfillment(
            of: [
                fetchExpectation1,
                clearExpectation1,
                fetchExpectation2,
                clearExpectation2,
                fetchExpectation3,
                clearExpectation3,
                fetchExpectation4,
                clearExpectation4,
                fetchExpectation5,
                clearExpectation5
            ],
            enforceOrder: true)
    }

    // MARK: - Private helper functions
    private func executeFetchTask(logins: [LoginProvider], expectation: XCTestExpectation) async {
        let result = await awsCognitoIdentityPoolOperations.fetchAWSCognitoIdentityPoolDetails(
            logins: logins,
            forceRefresh: false)
        XCTAssertEqual(try result.identityIdResult.get(), cognitoIdentityClient.mockIdentityId)
        XCTAssertEqual(try result.awsCredentialsResult.get().accessKeyId, cognitoIdentityClient.mockAccessKeyId)
        XCTAssertEqual(try result.awsCredentialsResult.get().expiration, cognitoIdentityClient.mockExpiration)
        XCTAssertEqual(try result.awsCredentialsResult.get().secretAccessKey, cognitoIdentityClient.mockSecretKey)
        XCTAssertEqual(try result.awsCredentialsResult.get().sessionToken, cognitoIdentityClient.mockSessionToken)
        expectation.fulfill()
    }

    private func executeClearTask(expectation: XCTestExpectation) async {
        do {
            var _ = try await awsCognitoIdentityPoolOperations.clearCredentials()
            expectation.fulfill()
        } catch {
            XCTFail("Credentials should be cleared")
        }
    }
}
