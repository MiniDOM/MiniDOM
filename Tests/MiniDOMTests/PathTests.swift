//
//  PathSimpleTests.swift
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

        let ids = result.compactMap({ $0.attributes?["id"] })
        XCTAssertEqual(["2", "10"], ids)
    }

    func testFindCNodes() {
        let result = document.evaluate(path: ["a", "b", "c"])
        XCTAssertEqual(result.count, 3)

        let ids = result.compactMap({ $0.attributes?["id"] })
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
            "    <z id='3'/>",
            "  </b>",
            "  <c id='4'>",
            "    <z id='5'/>",
            "  </c>",
            "  <b id='6'/>",
            "  <z id='7'/>",
            "  <b id='8'>",
            "    <z id='9'/>",
            "  </b>",
            "</a>",
        ].joined(separator: "\n")

        document = loadXML(string: source)
    }

    func testFindZElements() {
        let result = document.evaluate(path: ["a", "b", "z"])
        XCTAssertEqual(result.count, 2)

        let ids = result.compactMap({ $0.attributes?["id"] })
        XCTAssertEqual(["3", "9"], ids)
    }
}
