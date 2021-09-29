//
//  StringEscapingTests.swift
//  MiniDOMTests
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

@testable import MiniDOM
import XCTest

class StringEntityEscapingTests: XCTestCase {

    func testASCIIString() {
        XCTAssertEqual("The quick brown fox jumps over the lazy dog.".escapedString(),
                       "The quick brown fox jumps over the lazy dog.")
    }

    func testCRLF() {
        XCTAssertEqual("The quick\nbrown fox jumps\rover the lazy dog.".escapedString(),
                       "The quick\nbrown fox jumps\rover the lazy dog.")
    }

    func testSimplifiedChinese() {
        // Using BBEdit, saved as text file with UTF-16 encoding.
        // Then read using `xxd` in the terminal.
        // Contents:
        // 00000000: feff 4f60 597d ff0c 4e16 754c 000a       ..O`Y}..N.uL..

        XCTAssertEqual("你好，世界".escapedString(),
                       "&#x4f60;&#x597d;&#xff0c;&#x4e16;&#x754c;")
    }

    func testPredefinedEntities() {
        XCTAssertEqual("foo&bar<baz>qux'quux\"fnord".escapedString(),
                       "foo&amp;bar&lt;baz&gt;qux&apos;quux&quot;fnord")

        XCTAssertEqual("foo&bar<baz>qux'quux\"fnord".escapedString(shouldEscapePredefinedEntities: false),
                       "foo&bar<baz>qux'quux\"fnord")

        XCTAssertEqual("\"你好，世界\"".escapedString(shouldEscapePredefinedEntities: false),
                       "\"&#x4f60;&#x597d;&#xff0c;&#x4e16;&#x754c;\"")
    }
}
