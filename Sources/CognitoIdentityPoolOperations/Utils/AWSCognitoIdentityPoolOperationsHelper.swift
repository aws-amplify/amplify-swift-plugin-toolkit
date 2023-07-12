//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import Amplify

struct AWSCognitoIdentityPoolOperationsHelper {

    public static func checkPluginKeyAndVersionAreValid(pluginKey: String,
                                                        pluginVersion: String) throws {
        if pluginKey.isEmpty || pluginVersion.isEmpty {
            throw AuthError.validation("PluginKey/PluginVersion",
                                       "PluginKey/PluginVersion is empty",
                                       "Please input non-empty plugin key and version")
        }

        if pluginKey.count > 25 {
            throw AuthError.validation("PluginKey",
                                       "PluginKey is too long",
                                       "Plugin key should contain between 1-25 characters")
        }

        if pluginVersion.count > 10 {
            throw AuthError.validation("PluginVersion",
                                       "PluginVersion is too long",
                                       "Plugin version should contain between 1-10 characters")
        }

        if !pluginKey.isAlphaNumeric() {
            throw AuthError.validation("PluginKey",
                                       "PluginKey contains invalid characters",
                                       "Plugin key should contain only alphanumeric characters")
        }

        if !pluginVersion.followsSemanticVersioning() {
            throw AuthError.validation("PluginVersion",
                                       "PluginVersion contains invalid pattern",
                                       "Plugin version should follow semantic versioning <major>.<minor>.<patch>")
        }
    }
}
