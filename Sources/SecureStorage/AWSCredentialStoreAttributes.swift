//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

struct AWSCredentialStoreAttributes {

    var itemClass: String = AWSCredentialStore.Constants.ClassGenericPassword
    var service: String
    var accessGroup: String?
}

extension AWSCredentialStoreAttributes {

    func defaultGetQuery() -> [String: Any] {
        var query: [String: Any] = [
            AWSCredentialStore.Constants.Class: itemClass,
            AWSCredentialStore.Constants.AttributeService: service
        ]
        if let accessGroup = accessGroup {
            query[AWSCredentialStore.Constants.AttributeAccessGroup] = accessGroup
        }
        return query
    }

    func defaultSetQuery() -> [String: Any] {
        var query: [String: Any] = defaultGetQuery()
        query[AWSCredentialStore.Constants.AttributeAccessible] = AWSCredentialStore.Constants.AttributeAccessibleAfterFirstUnlockThisDeviceOnly
        query[AWSCredentialStore.Constants.UseDataProtectionKeyChain] = kCFBooleanTrue
        return query
    }
}
