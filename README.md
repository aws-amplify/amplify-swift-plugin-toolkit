# amplify-swift-plugin-toolkit

This package contains set of tools and public API definitions which can be used by plugin developers 
to create their custom Amplify plugins for different categories.

### Cognito Identity Pool Operations
---
This module provides convenient APIs to 

- fetch temporary AWS credentials and Cognito Identity ID in exchange of tokens from OIDC compliant Identity provider of your choice.
- It also implicitly provides APIs to store and manage the AWS credentials and Cognito Identity ID in a secure credential store.

### Secure Storage
---
This module provides API definitions for a secure credential store. It also comes with a concrete implementation of a credential store which is ready to use in your custom Amplify plugins.

## Platform Support
AmplifySwiftPluginToolkit supports the following platforms:

- iOS 13 and above
- macOS 10.15 and above
- tvOS 13 and above
- watchOS 7 and above

## Installation
### Swift Package Manager

Swift Package Manager is distributed with Xcode. To add AmplifySwiftPluginToolkit to your Xcode project, follow the steps below: 

1. Open your project in Xcode.
2. Select your application in the **Project Navigator**.
3. Select your project in the **Project List** pane.
4. Select **Package Dependencies**.
5. Click the + (plus) button.
6. Enter the AmplifySwiftPluginToolkit GitHub repo URL (`https://github.com/aws-amplify/amplify-swift-plugin-toolkit`) in the search bar labeled **Search or Enter Package URL**.
7. Click **Add Package** and select your desired **Dependency Rule**
8. Select the targets you would like to add.
    - **SecureStorage** provides a credential store for storing credentials in a secure manner
    - **CognitoIdentityPoolOperations** provides APIs to fetch temporary AWS credentials and Cognito Identity ID in exchange of tokens from an OIDC compliant Identity provider of your choice. It also implicitly provides convenient APIs to store and manage the AWS credentials and Cognito Identity ID for you.

## Reporting Bugs/Feature Requests

We welcome you to use the GitHub issue tracker to report bugs or suggest features.

When filing an issue, please check [existing open](https://github.com/aws-amplify/amplify-swift-plugin-toolkit/issues), or [recently closed](https://github.com/aws-amplify/amplify-swift-plugin-toolkit/issues?utf8=%E2%9C%93&q=is%3Aissue%20is%3Aclosed%20), issues to make sure somebody else hasn't already reported the issue. Please try to include as much information as you can. Details like these are incredibly useful:

* Expected behavior and observed behavior.
* A reproducible test case or series of steps.
* The version of our code being used.
* Any modifications you've made relevant to the bug.
* Anything custom about your environment or deployment.
* Stack Trace in text form (if applicable).

## Open Source Contributions

We welcome all contributions from the community! Make sure you read through our contribution guide [here](https://github.com/aws-amplify/amplify-swift-plugin-toolkit/blob/main/CONTRIBUTING.md) before submitting any pull requests.

## Security

See [CONTRIBUTING](https://github.com/aws-amplify/amplify-swift-plugin-toolkit/blob/main/CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This project is licensed under the Apache-2.0 License.