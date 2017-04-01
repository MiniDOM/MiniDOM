//
//  NodeTests.swift
//  MiniDOM
//
//  Created by Paul Calnan on 3/31/17.
//  Copyright © 2017 Anodized Software, Inc. All rights reserved.
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
}
