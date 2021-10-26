//
//  ContentsTests.swift
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

class ContentsTests: XCTestCase {
    var document: Document!

    override func setUp() {
        super.setUp()
        document = Document(string: contentsTestsSource)
    }

    func testThreeProcessingInstructions() {
        let pis = document.children(ofType: ProcessingInstruction.self)
        XCTAssertEqual(pis.count, 3)

        let pi0 = pis[0]
        XCTAssertEqual(pi0.target, "xml-stylesheet")
        XCTAssertEqual(pi0.data, "href=\"XSL\\JavaXML.html.xsl\" type=\"text/xsl\"")

        let pi1 = pis[1]
        XCTAssertEqual(pi1.target, "xml-stylesheet")
        XCTAssertEqual(pi1.data?.normalized, "href=\"XSL\\JavaXML.wml.xsl\" type=\"text/xsl\" media=\"wap\"")

        let pi2 = pis[2]
        XCTAssertEqual(pi2.target, "cocoon-process")
        XCTAssertEqual(pi2.data, "type=\"xslt\"")
    }

    func testOneComment() {
        let comments = document.children(ofType: Comment.self)
        XCTAssertEqual(comments.count, 1)

        let c0 = comments[0]
        XCTAssertEqual(c0.text.normalized, "Java and XML")
    }

    func testDocumentElement() {
        let de = document.rootElement
        XCTAssertNotNil(de)
        XCTAssertEqual(de?.nodeName, "JavaXML:Book")
        XCTAssertEqual(de?.attributes ?? [:], [
            "xmlns:JavaXML": "http://www.oreilly.com/catalog/javaxml/",
            "xmlns:ora": "http://www.oreilly.com",
            "xmlns:unused": "http://www.unused.com",
            "ora:category": "Java"
        ])
    }

    func testTwoElementsUnderDocumentElement() {
        let children = document.rootElement?.children(ofType: Element.self)
        XCTAssertEqual(children?.count, 2)
        XCTAssertEqual(children?.map({ $0.nodeName }) ?? [], ["JavaXML:Title", "JavaXML:Contents"])
    }

    func testFourChapterElements() {
        let chapterNodes = document.evaluate(path:
            ["JavaXML:Book", "JavaXML:Contents", "JavaXML:Chapter"])
        XCTAssertEqual(chapterNodes.count, 4)

        let headingTextValues = chapterNodes.compactMap { (chapterNode) -> String? in
            let textNodes = chapterNode.evaluate(path: ["JavaXML:Heading", "#text"])
            return textNodes.first(ofType: Text.self)?.text
        }
        XCTAssertEqual(headingTextValues.count, 4)

        XCTAssertEqual(headingTextValues, [
            "Introduction",
            "Creating XML",
            "Parsing XML",
            "Web Publishing Frameworks"
        ])
    }

    func testLastChild() {
        let de = document.rootElement
        let last = de?.lastChildElement
        XCTAssertNotNil(last)
        XCTAssertEqual(last?.nodeName, "JavaXML:Contents")
        XCTAssertEqual(last?.attributes ?? [:], ["xmlns:topic": "http://www.oreilly.com/topics"])
    }
}
