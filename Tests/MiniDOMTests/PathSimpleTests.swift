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

class PathSimpleTests: XCTestCase {
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

        let r0 = result[0]
        XCTAssertEqual(r0.nodeName, "b")
        XCTAssertEqual(r0.nodeType, NodeType.element)

        let e0 = r0 as? Element
        XCTAssertNotNil(e0)
        XCTAssertEqual(e0?.attributes?["id"], "2")

        let r1 = result[1]
        XCTAssertEqual(r1.nodeName, "b")
        XCTAssertEqual(r1.nodeType, NodeType.element)

        let e1 = r1 as? Element
        XCTAssertNotNil(e1)
        XCTAssertEqual(e1?.attributes?["id"], "10")
    }
}
