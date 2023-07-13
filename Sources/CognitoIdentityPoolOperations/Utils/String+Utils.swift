//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

extension String {

    /// Returns a masked version of the receiver.
    ///
    /// - Parameters:
    ///   - character: The character to obscure the interior of the string
    ///   - retainingCount: Number of characters to retain at both the beginning and end
    ///   of the string
    ///   - interiorCount: Number of masked characters in the interior of the string.
    ///   Defaults to actual size of string
    /// - Returns: A masked version of the string
    func masked(
        using character: Character = "*",
        interiorCount: Int = .max,
        retainingCount: Int = 2
    ) -> String {
        guard count >= retainingCount * 2 else {
            return String(repeating: character, count: count)
        }

        let interiorCharacterCount = count - (retainingCount * 2)
        let actualMaskSize = min(interiorCharacterCount, interiorCount)
        let mask = String(repeating: character, count: actualMaskSize)

        let prefix = prefix(retainingCount)
        let suffix = suffix(retainingCount)
        let maskedString = prefix + mask + suffix
        return String(maskedString)
    }

    func redacted() -> Self {
        "<REDACTED>"
    }
}

extension String? {
    func masked(
        using character: Character = "*",
        interiorCount: Int = .max,
        retainingCount: Int = 2
    ) -> String {
        switch self {
        case .none:
            return "(nil)"
        case .some(let value):
            return value.masked(
                using: character,
                interiorCount: interiorCount,
                retainingCount: retainingCount
            )
        }
    }

    func redacted() -> String {
        switch self {
        case .none:
            return "(nil)"
        case .some(let value):
            return value.redacted()
        }
    }

}

extension String {

    /// Check if string contains only alphanumeric characters
    func isAlphaNumeric() -> Bool {
        return self.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) == nil && self != ""
    }

    /// Check if string follows semantic versioning - <major>.<minor>.<patch>
    func followsSemanticVersioning() -> Bool {
        let semVerPattern = #"^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)?$"#
        let ret = self.range(of: semVerPattern, options: .regularExpression, range: nil, locale: nil)
        return ret != nil
    }
}
