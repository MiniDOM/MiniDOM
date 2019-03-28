//
//  NormalizeTests.swift
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

import MiniDOM
import XCTest

class NormalizeTests: XCTestCase {

    func testNormalizeTextNodesOnly() {
        var element = Element(tagName: "element", children: [
            Text(text: "this is "),
            Text(text: "a test"),
            Text(text: " of the normalization algorithm")
        ])

        element.normalize()
        XCTAssertEqual(element.nodeName, "element")
        XCTAssertEqual(element.children.count, 1)
        XCTAssertEqual(element.firstChild?.nodeType, .text)
        XCTAssertEqual(element.firstChild?.nodeValue, "this is a test of the normalization algorithm")
    }

    func testNormalizeMixed() {
        var element = Element(tagName: "element", children: [
            Text(text: "this is "),
            Text(text: "a test"),
            Element(tagName: "child"),
            Text(text: "of the normalization algorithm")
        ])

        element.normalize()
        XCTAssertEqual(element.nodeName, "element")
        XCTAssertEqual(element.children.count, 3)
        XCTAssertEqual(element.firstChild?.nodeType, .text)
        XCTAssertEqual(element.firstChild?.nodeValue, "this is a test")
        XCTAssertEqual(element.lastChild?.nodeType, .text)
        XCTAssertEqual(element.lastChild?.nodeValue, "of the normalization algorithm")
    }

    func testNormalizeChildren() {
        var element = Element(tagName: "element", children: [
            Text(text: "this is "),
            Text(text: "a test"),
            Element(tagName: "child", children: [
                Text(text: "the child element "),
                Text(text: "has text, too")
            ])
        ])

        element.normalize()
        XCTAssertEqual(element.nodeName, "element")
        XCTAssertEqual(element.children.count, 2)
        XCTAssertEqual(element.firstChild?.nodeType, .text)
        XCTAssertEqual(element.firstChild?.nodeValue, "this is a test")
        XCTAssertEqual(element.lastChild?.nodeType, .element)
        XCTAssertEqual(element.lastChild?.children.count, 1)
        XCTAssertEqual(element.lastChild?.firstChild?.nodeType, .text)
        XCTAssertEqual(element.lastChild?.firstChild?.nodeValue, "the child element has text, too")
    }
}
