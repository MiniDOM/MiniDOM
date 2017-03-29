//
//  ContentsTests.swift
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

class ContentsTests: XCTestCase {
    var document: Document!

    override func setUp() {
        super.setUp()
        document = loadXML(string: contentsTestsSource)
    }

    func testThreeProcessingInstructions() {
        let pis = document.children(ofType: ProcessingInstruction.self)
        XCTAssertEqual(pis.count, 3)

        let pi0 = pis[0]
        XCTAssertEqual(pi0.target, "xml-stylesheet")
        XCTAssertEqual(pi0.data, "href=\"XSL\\JavaXML.html.xsl\" type=\"text/xsl\"")

        let pi1 = pis[1]
        XCTAssertEqual(pi1.target, "xml-stylesheet")
        XCTAssertEqual(pi1.data?.normalized(), "href=\"XSL\\JavaXML.wml.xsl\" type=\"text/xsl\" media=\"wap\"")

        let pi2 = pis[2]
        XCTAssertEqual(pi2.target, "cocoon-process")
        XCTAssertEqual(pi2.data, "type=\"xslt\"")
    }

    func testOneComment() {
        let comments = document.children(ofType: Comment.self)
        XCTAssertEqual(comments.count, 1)

        let c0 = comments[0]
        XCTAssertEqual(c0.text.normalized(), "Java and XML")
    }

    func testDocumentElement() {
        let de = document.documentElement
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
        let children = document.documentElement?.children(ofType: Element.self)
        XCTAssertEqual(children?.count, 2)
        XCTAssertEqual(children?.map({ $0.nodeName }) ?? [], ["JavaXML:Title", "JavaXML:Contents"])
    }

    func testFourChapterElements() {
        let chapterNodes = document.evaluate(path:
            ["JavaXML:Book", "JavaXML:Contents", "JavaXML:Chapter"])
        XCTAssertEqual(chapterNodes.count, 4)

        let headingTextValues = chapterNodes.flatMap { (chapterNode) -> String? in
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
        let de = document.documentElement
        let last = de?.lastChild
        XCTAssertNotNil(last)
        XCTAssertEqual(last?.nodeName, "JavaXML:Contents")

        let lastElement = last as? Element
        XCTAssertEqual(lastElement?.attributes ?? [:], ["xmlns:topic": "http://www.oreilly.com/topics"])
    }
}
