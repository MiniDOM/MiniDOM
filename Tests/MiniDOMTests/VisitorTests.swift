//
//  VisitorTests.swift
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
import Nimble
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
                expect(document.children.count) == 1
            }

            func beginVisit(_ element: Element) {
                if element.tagName == "bar" {
                    expect(element.children.isEmpty).to(beTrue())
                }
                else {
                    expect(element.children.isEmpty).to(beFalse())
                }
            }

            func visit(_ text: Text) {
                expect(text.children.isEmpty).to(beTrue())
            }

            func visit(_ processingInstruction: ProcessingInstruction) {
                expect(processingInstruction.children.isEmpty).to(beTrue())
            }

            func visit(_ comment: Comment) {
                expect(comment.children.isEmpty).to(beTrue())
            }

            func visit(_ cdataSection: CDATASection) {
                expect(cdataSection.children.isEmpty).to(beTrue())
            }
        }

        let visitor = ChildCheckingVisitor()
        document.accept(visitor)
    }
}
