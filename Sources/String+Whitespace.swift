//
//  String+Whitespace.swift
//  MiniDOM
//
//  Copyright 2017 Anodized Software, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

public extension String {
    /**
     Returns a new string made by removing whitespace and newline characters 
     from both ends of the receiver.
     */
    public var trimmed: String {
        return trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }

    /**
     Returns a new string made by replacing multiple space whitespace characters
     (matching the `\\s` regular expression character class) with a single space
     character.
     */
    public var collapsed: String {
        return replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
    }

    /**
     Returns a new string made by normalizing the whitespace characters in the
     receiver. Leading and trailing whitespace characters are trimmed (via the
     `trimmed()` function), then newlines are replaced with spaces, finally
     whitespace is collapsed (via the `collapsed()` function).
     */
    public var normalized: String {
        return trimmed.replacingOccurrences(of: "\\n", with: " ").collapsed
    }
}
