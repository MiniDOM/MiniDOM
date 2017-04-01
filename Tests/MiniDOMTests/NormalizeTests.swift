//
//  NormalizeTests.swift
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
