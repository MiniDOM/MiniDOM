//
//  String+Whitespace.swift
//  MiniDOM
//
//  Copyright 2017-2019 Anodized Software, Inc.
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//

import Foundation

public extension String {
    /**
     Returns a new string made by removing whitespace and newline characters
     from both ends of the receiver.
     */
    var trimmed: String {
        return trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }

    /**
     Returns a new string made by replacing multiple space whitespace characters
     (matching the `\\s` regular expression character class) with a single space
     character.
     */
    var collapsed: String {
        return replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
    }

    /**
     Returns a new string made by normalizing the whitespace characters in the
     receiver. Leading and trailing whitespace characters are trimmed (via the
     `trimmed()` function), then newlines are replaced with spaces, finally
     whitespace is collapsed (via the `collapsed()` function).
     */
    var normalized: String {
        return trimmed.replacingOccurrences(of: "\\n", with: " ").collapsed
    }
}
