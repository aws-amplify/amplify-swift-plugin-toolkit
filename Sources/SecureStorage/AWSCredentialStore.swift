//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import Security

public protocol AWSCredentialStoreBehavior {

    /// Get a string value from the Keychain based on the key.
    /// - Parameter key: A String key use to look up the value in the Keychain
    /// - Returns: A string value
    func getString(_ key: String) throws -> String

    /// Get a data value from the Keychain based on the key.
    /// - Parameter key: A String key use to look up the value in the Keychain
    /// - Returns: A data value
    func getData(_ key: String) throws -> Data

    /// Set a key-value pair in the Keychain.
    /// - Parameters:
    ///   - value: A string value to store in Keychain
    ///   - key: A String key for the value to store in the Keychain
    func put(_ value: String, key: String) throws

    /// Set a key-value pair in the Keychain.
    /// - Parameters:
    ///   - value: A data value to store in Keychain
    ///   - key: A String key for the value to store in the Keychain
    func put(_ value: Data, key: String) throws

    /// Remove key-value pair from Keychain based on the provided key.
    /// - Parameter key: A String key to delete the key-value pair
    func remove(_ key: String) throws

    /// Removes all key-value pair in the Keychain.
    func removeAll() throws
}

public struct AWSCredentialStore: AWSCredentialStoreBehavior {

    let attributes: AWSCredentialStoreAttributes

    private init(attributes: AWSCredentialStoreAttributes) {
        self.attributes = attributes
    }

    public init() {
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
            fatalError("Unable to retrieve bundle identifier to initialize keychain")
        }
        self.init(service: bundleIdentifier)
    }

    public init(service: String) {
        self.init(service: service, accessGroup: nil)
    }

    public init(service: String, accessGroup: String? = nil) {
        var attributes = AWSCredentialStoreAttributes(service: service)
        attributes.accessGroup = accessGroup
        self.init(attributes: attributes)
    }

    /// Get a string value from the Keychain based on the key.
    /// - Parameter key: A String key use to look up the value in the Keychain
    /// - Returns: A string value
    public func getString(_ key: String) throws -> String {

        let data = try getData(key)

        guard let string = String(data: data, encoding: .utf8) else {
            throw AWSCredentialStoreError.conversionError(errorDescription: "Unable to create String from Data retrieved")
        }
        return string

    }

    /// Get a data value from the Keychain based on the key.
    /// - Parameter key: A String key use to look up the value in the Keychain
    /// - Returns: A data value
    public func getData(_ key: String) throws -> Data {
        var query = attributes.defaultGetQuery()

        query[Constants.MatchLimit] = Constants.MatchLimitOne
        query[Constants.ReturnData] = kCFBooleanTrue

        query[Constants.AttributeAccount] = key

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
        case errSecSuccess:
            guard let data = result as? Data else {
                throw AWSCredentialStoreError.unknown(errorDescription: "The keychain item retrieved is not the correct type")
            }
            return data
        case errSecItemNotFound:
            throw AWSCredentialStoreError.itemNotFound()
        default:
            throw AWSCredentialStoreError.securityError(osStatus: status)
        }
    }

    /// Set a key-value pair in the Keychain.
    /// - Parameters:
    ///   - value: A string value to store in Keychain
    ///   - key: A String key for the value to store in the Keychain
    public func put(_ value: String, key: String) throws {
        guard let data = value.data(using: .utf8, allowLossyConversion: false) else {
            throw AWSCredentialStoreError.conversionError(errorDescription: "Unable to create Data from String retrieved")
        }
        try put(data, key: key)
    }

    /// Set a key-value pair in the Keychain.
    /// - Parameters:
    ///   - value: A data value to store in Keychain
    ///   - key: A String key for the value to store in the Keychain
    public func put(_ value: Data, key: String) throws {
        var getQuery = attributes.defaultGetQuery()
        getQuery[Constants.AttributeAccount] = key

        let fetchStatus = SecItemCopyMatching(getQuery as CFDictionary, nil)
        switch fetchStatus {
        case errSecSuccess:

            var attributesToUpdate = [String: Any]()
            attributesToUpdate[Constants.ValueData] = value

            let updateStatus = SecItemUpdate(getQuery as CFDictionary, attributesToUpdate as CFDictionary)
            if updateStatus != errSecSuccess {
                throw AWSCredentialStoreError.securityError(osStatus: updateStatus)
            }
        case errSecItemNotFound:
            var attributesToSet = attributes.defaultSetQuery()
            attributesToSet[Constants.AttributeAccount] = key
            attributesToSet[Constants.ValueData] = value

            let addStatus = SecItemAdd(attributesToSet as CFDictionary, nil)
            if addStatus != errSecSuccess {
                throw AWSCredentialStoreError.securityError(osStatus: addStatus)
            }
        default:
            throw AWSCredentialStoreError.securityError(osStatus: fetchStatus)
        }
    }

    /// Remove key-value pair from Keychain based on the provided key.
    /// - Parameter key: A String key to delete the key-value pair
    public func remove(_ key: String) throws {
        var query = attributes.defaultGetQuery()
        query[Constants.AttributeAccount] = key

        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            throw AWSCredentialStoreError.securityError(osStatus: status)
        }
    }

    /// Removes all key-value pair in the Keychain.
    public func removeAll() throws {
        var query = attributes.defaultGetQuery()

        #if !os(iOS) && !os(watchOS) && !os(tvOS)
        query[Constants.MatchLimit] = Constants.MatchLimitAll
        #endif

        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            throw AWSCredentialStoreError.securityError(osStatus: status)
        }
    }

}

extension AWSCredentialStore {
    struct Constants {
        /** Class Key Constant */
        static let Class = String(kSecClass)
        static let ClassGenericPassword = String(kSecClassGenericPassword)

        /** Attribute Key Constants */
        static let AttributeAccessGroup = String(kSecAttrAccessGroup)
        static let AttributeAccount = String(kSecAttrAccount)
        static let AttributeService = String(kSecAttrService)
        static let AttributeGeneric = String(kSecAttrGeneric)
        static let AttributeLabel = String(kSecAttrLabel)
        static let AttributeComment = String(kSecAttrComment)
        static let AttributeAccessible = String(kSecAttrAccessible)

        /** Attribute Accessible Constants */
        static let AttributeAccessibleAfterFirstUnlockThisDeviceOnly = String(kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly)

        /** Search Constants */
        static let MatchLimit = String(kSecMatchLimit)
        static let MatchLimitOne = kSecMatchLimitOne
        static let MatchLimitAll = kSecMatchLimitAll

        /** Return Type Key Constants */
        static let ReturnData = String(kSecReturnData)
        static let ReturnAttributes = String(kSecReturnAttributes)

        /** Value Type Key Constants */
        static let ValueData = String(kSecValueData)

        /** Indicates whether to treat macOS keychain items like iOS keychain items without setting kSecAttrSynchronizable */
        static let UseDataProtectionKeyChain = String(kSecUseDataProtectionKeychain)
    }
}
