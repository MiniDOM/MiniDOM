//
//  FormatterTests.swift
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
