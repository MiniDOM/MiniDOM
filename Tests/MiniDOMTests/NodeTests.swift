//
//  NodeTests.swift
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
import MiniDOM
import XCTest

class NodeTests: XCTestCase {

    func testNormalizeLeafNode() {
        var text = Text(text: "Testing 1 2 3")
        text.normalize()
        XCTAssertEqual(text.text, "Testing 1 2 3")
    }

    func testHasChildElements() {
        let element = Element(tagName: "foo")
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

        let ids = foos.flatMap({ return $0.attributes?["id"] })
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

        let ids = foos.flatMap({ return $0.attributes?["id"] })
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
        XCTAssertNil(element.textValue)
    }

    func testNodeValueSingleTextChild() {
        let element = Element(tagName: "fnord", children: [
            Text(text: "bingo")
        ])
        XCTAssertEqual(element.textValue, "bingo")
    }
}
