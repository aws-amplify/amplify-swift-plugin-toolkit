//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest
@testable import Amplify
@testable import CognitoIdentityPoolOperations

class AuthHubEventEmitterTests: XCTestCase {

    var unsubscribeToken: UnsubscribeToken?

    /// Given: AuthHubEventEmitter API
    /// When: Signed in hub event is sent once and signed out hub event is sent multiple times
    /// Then: Hub listener should receive one event for sign in and one event for sign out
    func testDispatchMultipleHubEvents() async {
        let expectation = expectation(description: "Hub event received")
        expectation.expectedFulfillmentCount = 2
        unsubscribeToken = Amplify.Hub.listen(to: .auth) { payload in
            switch payload.eventName {
            case HubPayload.EventName.Auth.signedIn:
                expectation.fulfill()

            case HubPayload.EventName.Auth.signedOut:
                expectation.fulfill()

            default:
                break
            }
        }

        AWSAuthHubEventEmitter.sendHubEvent(eventName: HubPayload.EventName.Auth.signedIn)
        AWSAuthHubEventEmitter.sendHubEvent(eventName: HubPayload.EventName.Auth.signedOut)
        AWSAuthHubEventEmitter.sendHubEvent(eventName: HubPayload.EventName.Auth.signedOut)
        AWSAuthHubEventEmitter.sendHubEvent(eventName: HubPayload.EventName.Auth.signedOut)

        await fulfillment(of: [expectation], timeout: 10)
    }

}
