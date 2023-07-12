//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import AWSCognitoIdentity
import CognitoIdentityPoolOperations

class MockCognitoIdentityClient: CognitoIdentityClientProtocol {

    public var getIdCallCount = 0
    public var getCredentialsForIdentityCallCount = 0
    public var mockIdentityId = "mockIdentityId"
    public var mockAccessKeyId = "mockIdentityId"
    public var mockExpiration = Date.distantFuture
    public var mockSecretKey = "mockIdentityId"
    public var mockSessionToken = "mockIdentityId"
    private let config: AWSCognitoIdentityPoolConfiguration

    init(config: AWSCognitoIdentityPoolConfiguration) {
        self.config = config
    }

    func createIdentityPool(input: AWSCognitoIdentity.CreateIdentityPoolInput) async throws -> AWSCognitoIdentity.CreateIdentityPoolOutputResponse {
        return .init()
    }

    func deleteIdentities(input: AWSCognitoIdentity.DeleteIdentitiesInput) async throws -> AWSCognitoIdentity.DeleteIdentitiesOutputResponse {
        return .init()
    }

    func deleteIdentityPool(input: AWSCognitoIdentity.DeleteIdentityPoolInput) async throws -> AWSCognitoIdentity.DeleteIdentityPoolOutputResponse {
        return .init()
    }

    func describeIdentity(input: AWSCognitoIdentity.DescribeIdentityInput) async throws -> AWSCognitoIdentity.DescribeIdentityOutputResponse {
        return .init()
    }

    func describeIdentityPool(input: AWSCognitoIdentity.DescribeIdentityPoolInput) async throws -> AWSCognitoIdentity.DescribeIdentityPoolOutputResponse {
        return .init()
    }

    func getCredentialsForIdentity(input: AWSCognitoIdentity.GetCredentialsForIdentityInput) async throws -> AWSCognitoIdentity.GetCredentialsForIdentityOutputResponse {
        getCredentialsForIdentityCallCount += 1
        let credentials = CognitoIdentityClientTypes.Credentials(accessKeyId: mockAccessKeyId,
                                                                 expiration: mockExpiration,
                                                                 secretKey: mockSecretKey,
                                                                 sessionToken: mockSessionToken)
        return .init(credentials: credentials,
                     identityId: mockIdentityId)
    }

    func getId(input: AWSCognitoIdentity.GetIdInput) async throws -> AWSCognitoIdentity.GetIdOutputResponse {
        getIdCallCount += 1
        return .init(identityId: mockIdentityId)
    }

    func getIdentityPoolRoles(input: AWSCognitoIdentity.GetIdentityPoolRolesInput) async throws -> AWSCognitoIdentity.GetIdentityPoolRolesOutputResponse {
        return .init()
    }

    func getOpenIdToken(input: AWSCognitoIdentity.GetOpenIdTokenInput) async throws -> AWSCognitoIdentity.GetOpenIdTokenOutputResponse {
        return .init()
    }

    func getOpenIdTokenForDeveloperIdentity(input: AWSCognitoIdentity.GetOpenIdTokenForDeveloperIdentityInput) async throws -> AWSCognitoIdentity.GetOpenIdTokenForDeveloperIdentityOutputResponse {
        return .init()
    }

    func getPrincipalTagAttributeMap(input: AWSCognitoIdentity.GetPrincipalTagAttributeMapInput) async throws -> AWSCognitoIdentity.GetPrincipalTagAttributeMapOutputResponse {
        return .init()
    }

    func listIdentities(input: AWSCognitoIdentity.ListIdentitiesInput) async throws -> AWSCognitoIdentity.ListIdentitiesOutputResponse {
        return .init()
    }

    func listIdentityPools(input: AWSCognitoIdentity.ListIdentityPoolsInput) async throws -> AWSCognitoIdentity.ListIdentityPoolsOutputResponse {
        return .init()
    }

    func listTagsForResource(input: AWSCognitoIdentity.ListTagsForResourceInput) async throws -> AWSCognitoIdentity.ListTagsForResourceOutputResponse {
        return .init()
    }

    func lookupDeveloperIdentity(input: AWSCognitoIdentity.LookupDeveloperIdentityInput) async throws -> AWSCognitoIdentity.LookupDeveloperIdentityOutputResponse {
        return .init()
    }

    func mergeDeveloperIdentities(input: AWSCognitoIdentity.MergeDeveloperIdentitiesInput) async throws -> AWSCognitoIdentity.MergeDeveloperIdentitiesOutputResponse {
        return .init()
    }

    func setIdentityPoolRoles(input: AWSCognitoIdentity.SetIdentityPoolRolesInput) async throws -> AWSCognitoIdentity.SetIdentityPoolRolesOutputResponse {
        return .init()
    }

    func setPrincipalTagAttributeMap(input: AWSCognitoIdentity.SetPrincipalTagAttributeMapInput) async throws -> AWSCognitoIdentity.SetPrincipalTagAttributeMapOutputResponse {
        return .init()
    }

    func tagResource(input: AWSCognitoIdentity.TagResourceInput) async throws -> AWSCognitoIdentity.TagResourceOutputResponse {
        return .init()
    }

    func unlinkDeveloperIdentity(input: AWSCognitoIdentity.UnlinkDeveloperIdentityInput) async throws -> AWSCognitoIdentity.UnlinkDeveloperIdentityOutputResponse {
        return .init()
    }

    func unlinkIdentity(input: AWSCognitoIdentity.UnlinkIdentityInput) async throws -> AWSCognitoIdentity.UnlinkIdentityOutputResponse {
        return .init()
    }

    func untagResource(input: AWSCognitoIdentity.UntagResourceInput) async throws -> AWSCognitoIdentity.UntagResourceOutputResponse {
        return .init()
    }

    func updateIdentityPool(input: AWSCognitoIdentity.UpdateIdentityPoolInput) async throws -> AWSCognitoIdentity.UpdateIdentityPoolOutputResponse {
        return .init()
    }

}
