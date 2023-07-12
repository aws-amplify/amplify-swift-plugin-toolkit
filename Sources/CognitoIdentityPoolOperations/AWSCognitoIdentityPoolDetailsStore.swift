//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import SecureStorage
import AWSPluginsCore

protocol AWSCognitoIdentityPoolDetailsStoreBehavior {
    func saveAWSCognitoIdentityPoolDetails(_ credential: AWSAuthCredentials,
                                           _ identityId: String,
                                           _ loginsProvider: [LoginProvider]) throws
    func retrieveAWSCognitoIdentityPoolDetails() throws -> (AWSAuthCredentials, String, [LoginProvider])
    func deleteAWSCognitoIdentityPoolDetails() throws
}

class AWSCognitoIdentityPoolDetailsStore {

    // Credential store constants
    static let service = "com.amplify.awsCognitoIdentityPoolCredentialStore"

    // User defaults constants
    private static let userDefaultsNameSpace = "amplify_secure_storage_scopes.awsCognitoIdentityPoolCredentialStore"

    /// This UserDefault Key is used to check if Keychain already has items stored on a fresh install.
    ///
    /// If this flag doesn't exist, previous keychain values for Amplify are removed from the keychain. This property has internal visibility
    /// for testing purposes only.
    static var isKeychainConfiguredKey: String {
        "\(userDefaultsNameSpace).isKeychainConfigured"
    }

    private let identityPoolConfiguration: AWSCognitoIdentityPoolConfiguration
    private let credentialStoreBehavior: AWSCredentialStoreBehavior
    private let keySuffix: String

    /// Creates a credential store instance.
    ///
    /// - Parameters:
    ///   - authConfiguration: cognito identity pool configuration
    ///   - accessGroup: the accessGroup to use to share access to the Keychain. See the Apple article, [Sharing Access to
    ///     Keychain Items Among a Collection of Apps](https://developer.apple.com/documentation/security/keychain_services/keychain_items/sharing_access_to_keychain_items_among_a_collection_of_apps)
    init(identityPoolConfiguration: AWSCognitoIdentityPoolConfiguration,
         credentialStoreBehavior: AWSCredentialStoreBehavior,
         keySuffix: String,
         accessGroup: String? = nil) {
        self.identityPoolConfiguration = identityPoolConfiguration
        self.credentialStoreBehavior = credentialStoreBehavior
        self.keySuffix = keySuffix
        let userDefaults = UserDefaults.standard
        if !userDefaults.bool(forKey: AWSCognitoIdentityPoolDetailsStore.isKeychainConfiguredKey) {
            try? deleteAll()
            userDefaults.set(true, forKey: AWSCognitoIdentityPoolDetailsStore.isKeychainConfiguredKey)
        }
    }

    /// Returns the root of a key for accessing a KeychainStore value.
    /// The key is derived from the cognito identity pool ID
    ///
    /// - Parameter authConfiguration: cognito identity pool configuration
    /// - Returns: a key for accessing a KeychainStore value
    private func rootPrefix(
        for identityPoolConfiguration: AWSCognitoIdentityPoolConfiguration
    ) -> String {
        let poolId = identityPoolConfiguration.poolId
        return "amplify.\(poolId).\(keySuffix)"
    }

    /// Returns the KeychainStore key prefix for the current session.
    ///
    /// - Parameter authConfiguration: cognito identity pool configuration
    /// - Returns: the KeychainStore key for the current session
    private func sessionPrefix(
        for authConfiguration: AWSCognitoIdentityPoolConfiguration) -> String {
        let rootPrefix = rootPrefix(for: authConfiguration)
        let sessionPrefix = "\(rootPrefix).session"
        return sessionPrefix
    }

    private func credentialKey(
        for identityPoolConfiguration: AWSCognitoIdentityPoolConfiguration) -> String {
        let sessionPrefix = sessionPrefix(
            for: identityPoolConfiguration)
        let credentialKey = "\(sessionPrefix).credential"
        return credentialKey
    }

    private func identityIdKey(
        for identityPoolConfiguration: AWSCognitoIdentityPoolConfiguration) -> String {
        let sessionPrefix = sessionPrefix(
            for: identityPoolConfiguration)
        let identityIdKey = "\(sessionPrefix).identityId"
        return identityIdKey
    }

    private func loginsProviderKey(
        for identityPoolConfiguration: AWSCognitoIdentityPoolConfiguration) -> String {
        let sessionPrefix = sessionPrefix(
            for: identityPoolConfiguration)
        let identityIdKey = "\(sessionPrefix).loginsProvider"
        return identityIdKey
    }
}

extension AWSCognitoIdentityPoolDetailsStore: AWSCognitoIdentityPoolDetailsStoreBehavior {

    func saveAWSCognitoIdentityPoolDetails(_ credential: AWSAuthCredentials,
                                           _ identityId: String,
                                           _ loginsProvider: [LoginProvider]) throws {
        let credentialKey = credentialKey(for: identityPoolConfiguration)
        let encodedCredentials = try encode(object: credential)
        try credentialStoreBehavior.put(encodedCredentials, key: credentialKey)

        let identityIdKey = identityIdKey(for: identityPoolConfiguration)
        try credentialStoreBehavior.put(identityId, key: identityIdKey)

        let loginsProviderKey = loginsProviderKey(for: identityPoolConfiguration)
        let encodedLoginsProvider = try encode(object: loginsProvider)
        try credentialStoreBehavior.put(encodedLoginsProvider, key: loginsProviderKey)
    }

    func retrieveAWSCognitoIdentityPoolDetails() throws -> (AWSAuthCredentials, String, [LoginProvider]) {
        let key = credentialKey(for: identityPoolConfiguration)
        let authCredentialData = try credentialStoreBehavior.getData(key)
        let awsCredential: AWSAuthCredentials = try decode(data: authCredentialData)

        let identityIdKey = identityIdKey(for: identityPoolConfiguration)
        let identityId = try credentialStoreBehavior.getString(identityIdKey)

        let loginsProviderKey = loginsProviderKey(for: identityPoolConfiguration)
        let loginsProviderData = try credentialStoreBehavior.getData(loginsProviderKey)
        let loginsProvider: [LoginProvider] = try decode(data: loginsProviderData)

        return (awsCredential, identityId, loginsProvider)
    }

    func deleteAWSCognitoIdentityPoolDetails() throws {
        try credentialStoreBehavior.removeAll()
    }

    func deleteAll() throws {
        try credentialStoreBehavior.removeAll()
    }
}

/// Helpers for encoding and decoding
extension AWSCognitoIdentityPoolDetailsStore {

    func encode(object: some Codable) throws -> Data {
        do {
            return try JSONEncoder().encode(object)
        } catch {
            throw AWSCredentialStoreError.codingError(errorDescription: "Error occurred while encoding", error: error)
        }
    }

    func decode<T: Decodable>(data: Data) throws -> T {
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw AWSCredentialStoreError.codingError(errorDescription: "Error occurred while decoding", error: error)
        }
    }

}
