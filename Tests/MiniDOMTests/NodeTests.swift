//
//  NodeTests.swift
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

class NodeTests: XCTestCase {

    func testHasChildElements() {
        var element = Element(tagName: "foo")
        XCTAssertFalse(element.hasChildren)
        XCTAssertFalse(element.hasChildElements)

        element.children.append(Text(text: "testing"))
        XCTAssertTrue(element.hasChildren)
        XCTAssertFalse(element.hasChildElements)

        element.children.append(Element(tagName: "bar"))
        XCTAssertTrue(element.hasChildren)
        XCTAssertTrue(element.hasChildElements)
    }

    func testChildElements() {
        let element = Element(tagName: "fnord", children: [
            Element(tagName: "foo", attributes: ["id": "1"]),
            Element(tagName: "bar"),
            Element(tagName: "foo", attributes: ["id": "2"]),
            Element(tagName: "baz"),
            Element(tagName: "foo", attributes: ["id": "3"])
        ])

        let foos = element.childElements(withName: "foo")
        XCTAssertEqual(foos.count, 3)

        let ids = foos.compactMap({ return $0.attributes?["id"] })
        XCTAssertEqual(ids.count, 3)
        XCTAssertEqual(["1", "2", "3"], ids)
    }

    func testChildrenWithName() {
        let element = Element(tagName: "fnord", children: [
            Element(tagName: "foo", attributes: ["id": "1"]),
            Element(tagName: "bar"),
            Element(tagName: "foo", attributes: ["id": "2"]),
            Element(tagName: "baz"),
            Element(tagName: "foo", attributes: ["id": "3"])
        ])

        let foos = element.children(withName: "foo")
        XCTAssertEqual(foos.count, 3)

        let ids = foos.compactMap({ return $0.attributes?["id"] })
        XCTAssertEqual(ids.count, 3)
        XCTAssertEqual(["1", "2", "3"], ids)
    }

    func testNodeValueNoChildren() {
        let element = Element(tagName: "fnord")
        XCTAssertNil(element.textValue)
    }

    func testNodeValueNonTextChild() {
        let element = Element(tagName: "fnord", children: [
            Comment(text: "this space intentionally left blank")
        ])
        XCTAssertNil(element.textValue)
    }

    func testNodeValueMultipleTextChildren() {
        let element = Element(tagName: "fnord", children: [
            Text(text: "This is a text node"),
            Text(text: "This is also a text node")
        ])
        XCTAssertEqual(element.textValue, "This is a text node")
    }

    func testNodeValueSingleTextChild() {
        let element = Element(tagName: "fnord", children: [
            Text(text: "bingo")
        ])
        XCTAssertEqual(element.textValue, "bingo")
    }
}
