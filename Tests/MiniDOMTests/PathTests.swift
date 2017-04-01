//
//  PathSimpleTests.swift
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

class PathTests1: XCTestCase {
    var source: String!

    var document: Document!
    
    override func setUp() {
        super.setUp()

        source = [
            "<a id='1'>",
            "  <b id='2'>",
            "    <c id='3'>",
            "      <d id='4'>",
            "        <e id='5'>",
            "          <f id='6'/>",
            "        </e>",
            "      </d>",
            "    </c>",
            "    <c id='7'>",
            "      <d id='8'>",
            "        <e id='9'/>",
            "      </d>",
            "    </c>",
            "  </b>",
            "  <b id='10'>",
            "    <c id='11'>",
            "      <d id='12'>",
            "        <e id='13'/>",
            "      </d>",
            "    </c>",
            "  </b>",
            "</a>"
        ].joined(separator: "\n")

        document = loadXML(string: source)
    }

    func testFindBNodes() {
        let result = document.evaluate(path: ["a", "b"])
        XCTAssertEqual(result.count, 2)

        let ids = result.flatMap({ $0.attributes?["id"] })
        XCTAssertEqual(["2", "10"], ids)
    }

    func testFindCNodes() {
        let result = document.evaluate(path: ["a", "b", "c"])
        XCTAssertEqual(result.count, 3)

        let ids = result.flatMap({ $0.attributes?["id"] })
        XCTAssertEqual(["3", "7", "11"], ids)
    }
}

class PathTests2: XCTestCase {
    var source: String!

    var document: Document!

    override func setUp() {
        super.setUp()

        source = [
            "<a id='1'>",
            "  <b id='2'>",
            "    <fnord id='3'/>",
            "  </b>",
            "  <c id='4'>",
            "    <fnord id='5'/>",
            "  </c>",
            "  <b id='6'/>",
            "  <fnord id='7'/>",
            "  <b id='8'>",
            "    <fnord id='9'/>",
            "  </b>",
            "</a>",
        ].joined(separator: "\n")

        document = loadXML(string: source)
    }

    func testFindFnords() {
        let result = document.evaluate(path: ["a", "b", "fnord"])
        XCTAssertEqual(result.count, 2)

        let ids = result.flatMap({ $0.attributes?["id"] })
        XCTAssertEqual(["3", "9"], ids)
    }
}
