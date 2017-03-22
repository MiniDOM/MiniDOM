//
//  ParserSimpleTests.swift
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

        document = loadXML(string: source)
    }

    func testTopLevelElement() {
        let documentElement = document.documentElement

        expect(documentElement).notTo(beNil())
        expect(documentElement?.nodeName) == "foo"
        expect(documentElement?.tagName) == "foo"
    }

    func testDocumentElementChildNodes() {
        let children = document.documentElement?.children

        expect(children).notTo(beNil())
        expect(children).notTo(beEmpty())
        expect(children?.count) == 5

        expect(children?[0].nodeName) == "#comment"
        expect(children?[0].nodeValue) == " This is a comment "

        expect(children?[1].nodeName) == "bar"
        expect(children?[1].nodeValue).to(beNil())

        expect(children?[2].nodeName) == "target"
        expect(children?[2].nodeValue) == "attr=\"value\""

        expect(children?[3].nodeName) == "#cdata-section"
        expect(children?[3].nodeValue) == "<div>This is some HTML</div>"

        expect(children?[4].nodeName) == "baz"
        expect(children?[4].nodeValue).to(beNil())

        let bar = children?[1] as? Element
        expect(bar).notTo(beNil())
        expect(bar?.attributes) == [
            "attr1": "value1",
            "attr2": "value2"
        ]
    }

    func testTwoElementsNamedFnord() {
        let fnords = document.elements(withTagName: "fnord")
        expect(fnords.count) == 2

        expect(fnords[0].children.count) == 1
        expect(fnords[0].firstChild?.nodeType) == .text
        expect(fnords[0].firstChild?.nodeValue) == "This is some text"

        expect(fnords[1].children.count) == 1
        expect(fnords[1].firstChild?.nodeType) == .text
        expect(fnords[1].firstChild?.nodeValue) == "This is some more text"
    }
}
