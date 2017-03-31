//
//  NormalizeTests.swift
//  MiniDOM
//
//  Created by Paul Calnan on 3/30/17.
//  Copyright © 2017 Anodized Software, Inc. All rights reserved.
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
