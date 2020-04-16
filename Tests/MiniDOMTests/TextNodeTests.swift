//
//  TextNodeTests.swift
//  MiniDOM
//
//  Copyright 2017-2020 Anodized Software, Inc.
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
import MiniDOM
import XCTest

class TextNodeTests: XCTestCase {

    var source: String!

    var document: Document!

    override func setUp() {
        super.setUp()

        source = [
            "<feed>",
            "<item>",
            "<title>California Bill To Ban “Fake News” Would Be Disastrous for Political Speech</title>",
            "</item>",
            "<item>",
            "<title>Small ISPs Oppose Congress&#039;s Move to Abolish Privacy Protections</title>",
            "</item>",
            "</feed>"
        ].joined(separator: "\n")

        document = loadXML(string: source)
    }

    func testFirstTitle() {
        let title = document.elements(withTagName: "title").first
        XCTAssertNotNil(title)

        let titleTextNodes = title?.children(ofType: Text.self)
        XCTAssertNotNil(titleTextNodes)
        XCTAssertEqual(titleTextNodes?.count, 2)
        XCTAssertEqual(titleTextNodes?.compactMap({ $0.nodeValue }) ?? [],
                       ["California Bill To Ban ", "“Fake News” Would Be Disastrous for Political Speech"])
    }
}
