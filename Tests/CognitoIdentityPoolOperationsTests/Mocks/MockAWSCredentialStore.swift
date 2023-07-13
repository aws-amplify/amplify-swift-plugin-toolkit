//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import SecureStorage

class MockAWSCredentialStore: AWSCredentialStoreBehavior {

    var getDataCallCount = 0
    var getStringCallCount = 0
    var putStringCallCount = 0
    var putDataCallCount = 0
    var removeCallCount = 0
    var removeAllCalled = false
    var store: [String: String] = [:]

    func getData(_ key: String) throws -> Data {
        getDataCallCount += 1
        if let val = store[key] {
            return Data(val.utf8)
        }

        throw AWSCredentialStoreError.itemNotFound()
    }

    func getString(_ key: String) throws -> String {
        getStringCallCount += 1
        if let val = store[key] {
            return val
        }

        throw AWSCredentialStoreError.itemNotFound()
    }

    func put(_ value: String, key: String) throws {
        putStringCallCount += 1
        store[key] = value
    }

    func put(_ value: Data, key: String) throws {
        putDataCallCount += 1
        let str = String(decoding: value, as: UTF8.self)
        store[key] = str
    }

    func remove(_ key: String) throws {
        removeCallCount += 1
        store.removeValue(forKey: key)
    }

    func removeAll() throws {
        removeAllCalled = true
        store.removeAll()
    }
}
