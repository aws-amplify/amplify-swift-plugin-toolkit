//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import AWSCognitoIdentity
import AWSPluginsCore
import SecureStorage
import Foundation

/// A contract for fetching AWS Credentials and Cognito Identity ID
/// by exchanging access tokens from your OIDC compliant identity provider
///
/// Call `fetchAWSCognitoIdentityPoolDetails()` with your login provider details to fetch
/// temporary AWS credentials
///
/// Call `clearCredentials()` to clear saved credentials and identity ID
public protocol AWSCognitoIdentityPoolOperationsBehavior {

    /// If your identity pool is configured for unauthenticated role, pass in empty login provider array.
    /// For authenticated roles, pass in `LoginProvider` instances.
    /// Passing `forceRefresh` as `true` will force refresh the internal session.
    func fetchAWSCognitoIdentityPoolDetails(logins: [LoginProvider],
                                            forceRefresh: Bool) async -> AWSCognitoIdentityPoolDetails

    
    /// Clears the stored credentials and identity ID from the credential store
    func clearCredentials() async throws
}

/// A type representing a login provider for federating into
/// [Cognito identity pools](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-identity.html).
public struct LoginProvider: Codable, Equatable {
    /// The login provider name. This must be a valid Cognito identity pools authentication provider.
    /// See [identity pools documentation](https://docs.aws.amazon.com/cognito/latest/developerguide/external-identity-providers.html)
    public let name: String
    
    /// A provider token that uniquely and securely identifies the user in the provider. For OIDC-compliant login providers,
    /// this will be the identity token.
    public let userIdentifier: String

    public init(providerName: String, providerUserIdentifier: String) {
        self.name = providerName
        self.userIdentifier = providerUserIdentifier
    }
}

/// A holder for Cognito identity pool operation results
public struct AWSCognitoIdentityPoolDetails {
    /// The result of the most recent attempt to get AWS Credentials. There is no guarantee that the credentials
    /// are not expired, but conforming types may have logic in place to automatically refresh the credentials.
    /// The credentials may be for either the unauthenticated or authenticated role, depending on the configuration of the
    /// identity pool and the tokens used to retrieve the identity ID from Cognito.
    ///
    /// If the most recent attempt caused an error, the result will contain the details of the error.
    /// Error can be of following types:
    /// case .configuration() - Caused by issue in the way auth category is configured
    /// case .service() - Caused by some error in the underlying service. Check the associated error for more details.
    /// case .unknown() - Caused by an unknown reason
    /// case .validation() - Caused when one of the input field is invalid
    /// case .notAuthorized() - Caused when the current session is not authorized to perform an operation
    /// case .invalidState() - Caused when an operation is not valid with the current state of Auth category
    /// case .signedOut() - Caused when an operation needs the user to be in signedIn state
    /// case .sessionExpired() - Caused when a session is expired and needs the user to be re-authenticated
    public let awsCredentialsResult: Result<AWSTemporaryCredentials, AuthError>
    
    /// The result of the most recent attempt to get AWS Credentials. There is no guarantee that the credentials
    /// are not expired, but conforming types may have logic in place to automatically refresh the credentials.
    /// The credentials may be fore either the unauthenticated or authenticated role, depending on the configuration of the
    /// identity pool and the tokens used to retrieve the identity ID from Cognito.
    ///
    /// If the most recent attempt caused an error, the result will contain the details of the error.
    /// Error can be of following types:
    /// case .configuration() - Caused by issue in the way auth category is configured
    /// case .service() - Caused by some error in the underlying service. Check the associated error for more details.
    /// case .unknown() - Caused by an unknown reason
    /// case .validation() - Caused when one of the input field is invalid
    /// case .notAuthorized() - Caused when the current session is not authorized to perform an operation
    /// case .invalidState() - Caused when an operation is not valid with the current state of Auth category
    /// case .signedOut() - Caused when an operation needs the user to be in signedIn state
    /// case .sessionExpired() - Caused when a session is expired and needs the user to be re-authenticated
    public let identityIdResult: Result<String, AuthError>

    /// Creates a new AWSCognitoIdentityPoolDetails with the specified results
    init(awsCredentialsResult: Result<AWSTemporaryCredentials, AuthError>, awsIdentityIdResult: Result<String, AuthError>) {
        self.awsCredentialsResult = awsCredentialsResult
        self.identityIdResult = awsIdentityIdResult
    }
}

public struct AWSCognitoIdentityPoolConfiguration {
    public let region: String
    public let poolId: String

    public init(region: String, identityPoolId: String ) {
        self.region = region
        self.poolId = identityPoolId
    }
}

/// A concrete implementation of the `AWSCognitoIdentityPoolOperationsBehavior`
/// This is a ready to use implementation in your custom Auth Category plugin for
/// Amplify to fetch and manage AWS Credentials and Cognito Identity ID
public class AWSCognitoIdentityPoolOperations: AWSCognitoIdentityPoolOperationsBehavior {

    public let cognitoIdentityPoolConfiguration: AWSCognitoIdentityPoolConfiguration
    public let cognitoIdentityClient: CognitoIdentityClientProtocol
    private let awsCognitoIdentityPoolDetailsStoreBehavior: AWSCognitoIdentityPoolDetailsStoreBehavior
    private let pluginKey: String
    private let pluginVersion: String
    private let taskQueue: TaskQueue<Any>

    /// Convenience initializer for `AWSCognitoIdentityPoolOperations`
    /// Parameters:
    ///     cognitoIdentityPoolConfiguration - configuration object containing information about identity pool
    ///     pluginKey - a unique string identifier for your plugin - should be 1-25 characters long and alphanumeric
    ///     pluginVersion - a unique version string following semantic versioning - <major>.<minor>.<patch> and should be
    ///                     1-10 characters long
    public convenience init(
        cognitoIdentityPoolConfiguration: AWSCognitoIdentityPoolConfiguration,
        pluginKey: String,
        pluginVersion: String = "1.0.0"
    ) throws {
        let configuration = try CognitoIdentityClient.CognitoIdentityClientConfiguration(
            frameworkMetadata: AmplifyAWSServiceConfiguration.swiftPluginToolkitMetadata(pluginKey: pluginKey,
                                                                                         pluginVersion: pluginVersion),
            region: cognitoIdentityPoolConfiguration.region
        )
        let cognitoIdentityClient = CognitoIdentityClient(config: configuration)
        let awsCredentialStoreBehavior = AWSCognitoIdentityPoolDetailsStore(
            identityPoolConfiguration: cognitoIdentityPoolConfiguration,
            credentialStoreBehavior: AWSCredentialStore(service: AWSCognitoIdentityPoolDetailsStore.service),
            keySuffix: pluginKey,
            accessGroup: nil)
        try self.init(cognitoIdentityPoolConfiguration: cognitoIdentityPoolConfiguration,
                      cognitoIdentityClient: cognitoIdentityClient,
                      cognitoIdentityPoolDetailsStoreBehavior: awsCredentialStoreBehavior,
                      pluginKey: pluginKey,
                      pluginVersion: pluginVersion
        )
    }

    init(cognitoIdentityPoolConfiguration: AWSCognitoIdentityPoolConfiguration,
         cognitoIdentityClient: CognitoIdentityClientProtocol,
         cognitoIdentityPoolDetailsStoreBehavior: AWSCognitoIdentityPoolDetailsStoreBehavior,
         pluginKey: String,
         pluginVersion: String) throws {
        try AWSCognitoIdentityPoolOperationsHelper.checkPluginKeyAndVersionAreValid(pluginKey: pluginKey,
                                                                                    pluginVersion: pluginVersion)

        self.cognitoIdentityPoolConfiguration = cognitoIdentityPoolConfiguration
        self.cognitoIdentityClient = cognitoIdentityClient
        self.awsCognitoIdentityPoolDetailsStoreBehavior = cognitoIdentityPoolDetailsStoreBehavior
        self.pluginKey = pluginKey
        self.pluginVersion = pluginVersion
        self.taskQueue = TaskQueue()
    }

    public func fetchAWSCognitoIdentityPoolDetails(logins: [LoginProvider],
                                                   forceRefresh: Bool) async -> AWSCognitoIdentityPoolDetails {
        do {
            return try await taskQueue.sync {

                var loginsMap: [String: String] = [:]
                for loginProvider in logins {
                    loginsMap[loginProvider.name] = loginProvider.userIdentifier
                }

                do {
                    // get identity id, credentials and login provider from keychain
                    let savedCognitoIdentityPoolDetails = try self.awsCognitoIdentityPoolDetailsStoreBehavior.retrieveAWSCognitoIdentityPoolDetails()
                    let savedCredentials = savedCognitoIdentityPoolDetails.0
                    let savedIdentityId = savedCognitoIdentityPoolDetails.1
                    let savedLoginsProvider = savedCognitoIdentityPoolDetails.2

                    // check if savedLoginsProvider is different from the one passed
                    // note: this can also include moving from unauth role to auth role
                    //       where Cognito can reuse the saved identity id and elevate it
                    //       to auth role
                    let isNewLogin = savedLoginsProvider != logins

                    if isNewLogin ||
                        self.areCredentialsExpired(awsCredentials: savedCredentials) ||
                        forceRefresh {
                        return await self.fetchAWSCredentialsAndUpdateSavedState(identityId: savedIdentityId,
                                                                                 loginsMap: loginsMap,
                                                                                 logins: logins)
                    } else {
                        return AWSCognitoIdentityPoolDetails(awsCredentialsResult: .success(savedCredentials),
                                                             awsIdentityIdResult: .success(savedIdentityId))
                    }
                } catch let error as AWSCredentialStoreError {
                    // check if there are no saved cognito identity pool details
                    // if the error is something else, return error
                    guard AWSCredentialStoreError.itemNotFound == error else {
                        let authError = AuthError(errorDescription: error.errorDescription,
                                                  recoverySuggestion: error.recoverySuggestion,
                                                  error: error)
                        return AWSCognitoIdentityPoolDetails(awsCredentialsResult: .failure(authError),
                                                             awsIdentityIdResult: .failure(authError))
                    }

                    do {
                        let identityId = try await self.fetchAWSIdentityId(logins: loginsMap)
                        return await self.fetchAWSCredentialsAndUpdateSavedState(identityId: identityId,
                                                                                 loginsMap: loginsMap,
                                                                                 logins: logins)
                    } catch let error {
                        return AWSCognitoIdentityPoolDetails(awsCredentialsResult: .failure(AuthError(error: error)),
                                                             awsIdentityIdResult: .failure(AuthError(error: error)))
                    }
                } catch let error {
                    // when error occurred is something else besides `AWSCredentialStoreError`
                    // which is thrown by `AWSCredentialStore`, return error
                    return AWSCognitoIdentityPoolDetails(awsCredentialsResult: .failure(AuthError(error: error)),
                                                         awsIdentityIdResult: .failure(AuthError(error: error)))
                }

            } as! AWSCognitoIdentityPoolDetails
        } catch {
            fatalError("Starting a task in fetchAWSCognitoIdentityPoolDetails() failed with error: \(error)")
        }
    }

    public func clearCredentials() async throws {
        return try await taskQueue.sync {
            try self.awsCognitoIdentityPoolDetailsStoreBehavior.deleteAWSCognitoIdentityPoolDetails()
        } as! Void
    }

    private func fetchAWSCredentialsAndUpdateSavedState(
        identityId: String,
        loginsMap: [String: String],
        logins: [LoginProvider]) async -> AWSCognitoIdentityPoolDetails {
            do {
                let (credentials, newIdentityId) = try await fetchAWSCredentials(
                    identityId: identityId,
                    loginsMap: loginsMap)
                try self.awsCognitoIdentityPoolDetailsStoreBehavior.saveAWSCognitoIdentityPoolDetails(credentials,
                                                                                                      newIdentityId,
                                                                                                      logins)
                return AWSCognitoIdentityPoolDetails(awsCredentialsResult: .success(credentials),
                                                     awsIdentityIdResult: .success(newIdentityId))
            } catch {
                return AWSCognitoIdentityPoolDetails(awsCredentialsResult: .failure(AuthError(error: error)),
                                                     awsIdentityIdResult: .failure(AuthError(error: error)))
            }
        }

    private func fetchAWSCredentials(identityId: String,
                                     loginsMap: [String: String]) async throws -> (AWSAuthCredentials, String) {

        let input = GetCredentialsForIdentityInput(
            customRoleArn: nil,
            identityId: identityId,
            logins: loginsMap
        )

        let response = try await cognitoIdentityClient.getCredentialsForIdentity(input: input)
        guard let responseCredentials = response.credentials,
              let responseIdentityId = response.identityId else {
            throw AuthError.service(
                "Credentials was unexpectedly nil in GetCredentialsForIdentity response",
                AmplifyErrorMessages.shouldNotHappenReportBugToAWS()
            )
        }

        let awsAuthCredentials = try AWSAuthCredentials(cognitoIdentityCredentials: responseCredentials)

        return (awsAuthCredentials, responseIdentityId)
    }

    private func fetchAWSIdentityId(logins: [String: String]) async throws -> String {

        let input = GetIdInput(
            identityPoolId: cognitoIdentityPoolConfiguration.poolId,
            logins: logins
        )

        let response = try await cognitoIdentityClient.getId(input: input)

        guard let identityId = response.identityId else {
            throw AuthError.service(
                "IdentityId was unexpectedly nil in GetId response",
                AmplifyErrorMessages.shouldNotHappenReportBugToAWS()
            )
        }

        return identityId
    }

    private func areCredentialsExpired(awsCredentials: AWSTemporaryCredentials) -> Bool {
        if awsCredentials.expiration < Date() {
            return true
        } else {
            return false
        }
    }
}
