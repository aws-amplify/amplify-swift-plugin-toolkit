//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import Amplify

/// A helper for sending events to the Amplify Hub
public struct AWSAuthHubEventEmitter {

    private static var lastSentEventName: AtomicValue<String?> = AtomicValue(initialValue: nil)

    /// Given a hub event named `eventName`, send the event to the Amplify Hub if `eventName` was not the most
    /// recent event sent via this method. For example:
    ///
    /// ```
    /// sendHubEvent("foo") // Emits a hub event named "foo"
    /// sendHubEvent("foo") // Does not emit a hub event, since the last event was named "foo"
    /// sendHubEvent("bar") // Emits a hub event named "bar"
    /// sendHubEvent("foo") // Emits a hub event named "foo", since the last event was not named "foo"
    /// ```
    /// - Parameter eventName: the name of the event to send
    public static func sendHubEvent(eventName: String) {
        if lastSentEventName.get() != eventName {
            lastSentEventName.set(eventName)
            Amplify.Hub.dispatch(to: .auth,
                                 payload: HubPayload(eventName: eventName))
        }
    }

}
