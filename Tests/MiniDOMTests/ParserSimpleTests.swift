//
//  ParserSimpleTests.swift
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

class ParserSimpleTests: XCTestCase {
    var source: String!

    var document: Document!

    override func setUp() {
        super.setUp()

        source = [
            "<?xml version=\"1.0\" encoding=\"utf-8\"?>",
            "<foo>",
            "  <!-- This is a comment -->",
            "  <bar attr1=\"value1\" attr2=\"value2\"/>",
            "  <?target attr=\"value\"?>",
            "  <![CDATA[<div>This is some HTML</div>]]>",
            "  <baz>",
            "    <fnord>",
            "      This is some text",
            "    </fnord>",
            "    <fnord>",
            "      This is some more text",
            "    </fnord>",
            "  </baz>",
            "</foo>"
        ].joined(separator: "\n")

        document = Document(string: source)
    }

    func testTopLevelElement() {
        let documentElement = document.rootElement

        XCTAssertNotNil(documentElement)
        XCTAssertEqual(documentElement?.nodeName, "foo")
        XCTAssertEqual(documentElement?.tagName, "foo")
    }

    func testDocumentElementChildNodes() {
        let children = document.rootElement?.children.filter({ $0.nodeType != .text })

        XCTAssertNotNil(children)
        XCTAssertEqual(children?.isEmpty, false)
        XCTAssertEqual(children?.count, 5)

        XCTAssertEqual(children?[0].nodeName, "#comment")
        XCTAssertEqual(children?[0].nodeValue, " This is a comment ")

        XCTAssertEqual(children?[1].nodeName, "bar")
        XCTAssertNil(children?[1].nodeValue)

        XCTAssertEqual(children?[2].nodeName, "target")
        XCTAssertEqual(children?[2].nodeValue, "attr=\"value\"")

        XCTAssertEqual(children?[3].nodeName, "#cdata-section")
        XCTAssertEqual(children?[3].nodeValue, "<div>This is some HTML</div>")

        XCTAssertEqual(children?[4].nodeName, "baz")
        XCTAssertNil(children?[4].nodeValue)

        let bar = children?[1] as? Element
        XCTAssertNotNil(bar)
        XCTAssertEqual(bar?.attributes ?? [:], [
            "attr1": "value1",
            "attr2": "value2"
        ])
    }

    func testTwoElementsNamedFnord() {
        let fnords = document.elements(withTagName: "fnord")
        XCTAssertEqual(fnords.count, 2)

        XCTAssertEqual(fnords[0].children.count, 1)
        XCTAssertEqual(fnords[0].firstChild?.nodeType, .text)
        XCTAssertEqual(fnords[0].firstChild?.nodeValue?.trimmed, "This is some text")

        XCTAssertEqual(fnords[1].children.count, 1)
        XCTAssertEqual(fnords[1].firstChild?.nodeType, .text)
        XCTAssertEqual(fnords[1].firstChild?.nodeValue?.trimmed, "This is some more text")
    }
}
