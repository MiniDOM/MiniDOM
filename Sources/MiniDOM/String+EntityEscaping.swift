//
//  String+EntityEscaping.swift
//  MiniDOM
//
//  Copyright 2017-2021 Anodized Software, Inc.
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

extension String {

    private static let predefinedEntities: [Unicode.Scalar: String] = [
        "&": "&amp;",
        "<": "&lt;",
        ">": "&gt;",
        "'": "&apos;",
        "\"": "&quot;"
    ]

    private static let nonEscapedRange: ClosedRange<Unicode.Scalar> = .init(uncheckedBounds: (Unicode.Scalar(0x20), Unicode.Scalar(0x7F)))

    func escapedString(shouldEscapePredefinedEntities: Bool = true) -> String {
        var output = ""

        for scalar in self.unicodeScalars {
            // Is it one of the standard entities?
            if Self.nonEscapedRange.contains(scalar) {
                if shouldEscapePredefinedEntities, let entity = Self.predefinedEntities[scalar] {
                    output.append(entity)
                }
                else {
                    output.append(scalar.description)
                }
            }
            else {
                output.append(String(format: "&#x%X;", scalar.value))
            }
        }

        return output
    }
}
