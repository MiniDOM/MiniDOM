//
//  ParserStreamTests.swift
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

class ParserStreamTests: XCTestCase {

    let sourceData = [
        "<?xml version=\"1.0\" encoding=\"utf-8\"?>",
        "<foo attr=\"val\">",
        "  <!-- This is a comment -->",
        "  <bar attr1=\"value1\" attr2=\"value2\"/>",
        "  <?target attr=\"value\"?>",
        "  <![CDATA[<div>This is some HTML</div>]]>",
        "  <baz>",
        "    <fnord>",
        "      This is some text",
        "    </fnord>",
        "    <fnord attr1=\"value1\">",
        "      This is some more text",
        "    </fnord>",
        "  </baz>",
        "</foo>"
    ].joined(separator: "\n").data(using: .utf8)!

    func testFullElementStream() {
        let parser = SAXParser(data: sourceData)

        var elements = [Element]()

        parser.streamElements { element in
            elements.append(element)
            return true
        } filter: { name, attributes in
            attributes["attr"] == "val" || name == "fnord"
        }

        XCTAssertEqual(elements.count, 3)
        XCTAssertEqual(elements[0].tagName, "fnord")
        XCTAssertEqual(elements[0].textValue?.trimmed, "This is some text")
        XCTAssertEqual(elements[1].tagName, "fnord")
        XCTAssertEqual(elements[1].textValue?.trimmed, "This is some more text")
        XCTAssertEqual(elements[2].tagName, "foo")
    }

    func testPartialElementStream() {
        let parser = SAXParser(data: sourceData)

        var foundElement: Element?

        parser.streamElements { element in
            foundElement = element
            return false
        } filter: { name, _ in
            name == "bar"
        }

        XCTAssertNotNil(foundElement)
        XCTAssertEqual(foundElement?.tagName, "bar")
        XCTAssertEqual(foundElement?.children.count, 0)
    }
}
