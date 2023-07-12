//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import AWSClientRuntime
import AWSPluginsCore
import AmplifySwiftPluginToolkit

struct AWSCognitoIdentityPoolOperationsUserAgent {

    public static let oidcPluginPlatformName = "oidc-auth-plugin"

}

extension AmplifyAWSServiceConfiguration {

    /// Returns basic amount of metadata that includes both
    /// [AmplifyAWSServiceConfiguration.amplifyVersion](x-source-tag://AmplifyAWSServiceConfiguration.amplifyVersion)
    /// and
    /// [AmplifyAWSServiceConfiguration.platformName](x-source-tag://AmplifyAWSServiceConfiguration.platformName)
    /// in addition to the operating system version if `includesOS` is set to `true`.
    ///
    /// - Tag: AmplifyAWSServiceConfiguration.frameworkMetaDataWithOS
    public static func swiftPluginToolkitMetadata(pluginKey: String,
                                                  pluginVersion: String,
                                                  includeOS: Bool = false) -> FrameworkMetadata {
        let osKey = "os"
        var extras = [platformName: amplifyVersion]
        if includeOS {
            extras[osKey] = frameworkOS()
        }

        extras[pluginKey] = pluginVersion

        return FrameworkMetadata(name: AWSCognitoIdentityPoolOperationsUserAgent.oidcPluginPlatformName,
                                 version: AmplifySwiftPluginToolkit.version,
                                 extras: extras)
    }

    private static func frameworkOS() -> String {
        // Please note that because the value returned by this function will be
        // sanitized by FrameworkMetadata by removing anything not in a special
        // character set that does NOT include the forward slash (/), the
        // backslash (\) is used as a separator instead.
        let separator = "\\"
        let operatingSystem = DeviceInfo.current.operatingSystem
        return [operatingSystem.name, operatingSystem.version].joined(separator: separator)
    }

}
