//
//  VisitorTests.swift
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

class VisitorTests: XCTestCase {
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

        document = loadXML(string: source)
    }

    func testEmptyVisitor() {
        class EmptyVisitor: Visitor { }
        let visitor = EmptyVisitor()
        document.accept(visitor)
    }

    func testChildren() {
        class ChildCheckingVisitor: Visitor {
            func beginVisit(_ document: Document) {
                XCTAssertEqual(document.children.count, 1)
            }

            func beginVisit(_ element: Element) {
                if element.tagName == "bar" {
                    XCTAssertTrue(element.children.isEmpty)
                }
                else {
                    XCTAssertFalse(element.children.isEmpty)
                }
            }

            func visit(_ text: Text) {
                XCTAssertTrue(text.children.isEmpty)
            }

            func visit(_ processingInstruction: ProcessingInstruction) {
                XCTAssertTrue(processingInstruction.children.isEmpty)
            }

            func visit(_ comment: Comment) {
                XCTAssertTrue(comment.children.isEmpty)
            }

            func visit(_ cdataSection: CDATASection) {
                XCTAssertTrue(cdataSection.children.isEmpty)
            }
        }

        let visitor = ChildCheckingVisitor()
        document.accept(visitor)
    }
}
