//
//  FormatterTests.swift
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

import Foundation
import MiniDOM
import XCTest

class FormatterTests: XCTestCase {
    var source: String!

    var expectedPrettyPrinted: String!

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
            "    <fnord>This is some text</fnord>",
            "    <fnord>This is some more text</fnord>",
            "  </baz>",
            "  <qux/>",
            "</foo>"
        ].joined(separator: "\n")

        expectedPrettyPrinted = [
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
            "  <qux/>",
            "</foo>"
        ].joined(separator: "\n")

        document = loadXML(string: source)
    }

    func testReproduceSourceString() {
        let formatted = document.prettyPrint(indentWith: "  ")
        XCTAssertNotNil(formatted)
        XCTAssertEqual(formatted, expectedPrettyPrinted)
    }

    func testDumper() {
        let formatted = document.dump()
        XCTAssertNotNil(formatted)
        XCTAssertEqual(formatted, source)
    }

}
