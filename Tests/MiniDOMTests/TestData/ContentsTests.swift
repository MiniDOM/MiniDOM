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
import Nimble
import XCTest

class ContentsTests: XCTestCase {
    var document: Document!
    
    override func setUp() {
        super.setUp()
        document = loadXML(string: contentsTestsSource)
    }

    func testThreeProcessingInstructions() {
        let pis = document.children(ofType: ProcessingInstruction.self)
        expect(pis.count) == 3

        let pi0 = pis[0]
        expect(pi0.target) == "xml-stylesheet"
        expect(pi0.data) == "href=\"XSL\\JavaXML.html.xsl\" type=\"text/xsl\""

        let pi1 = pis[1]
        expect(pi1.target) == "xml-stylesheet"
        expect(pi1.data?.normalized()) == "href=\"XSL\\JavaXML.wml.xsl\" type=\"text/xsl\" media=\"wap\""

        let pi2 = pis[2]
        expect(pi2.target) == "cocoon-process"
        expect(pi2.data) == "type=\"xslt\""
    }

    func testOneComment() {
        let comments = document.children(ofType: Comment.self)
        expect(comments.count) == 1

        let c0 = comments[0]
        expect(c0.text.normalized()) == "Java and XML"
    }

    func testDocumentElement() {
        let de = document.documentElement
        expect(de).notTo(beNil())
        expect(de?.nodeName) == "JavaXML:Book"
        expect(de?.attributes) == [
            "xmlns:JavaXML": "http://www.oreilly.com/catalog/javaxml/",
            "xmlns:ora": "http://www.oreilly.com",
            "xmlns:unused": "http://www.unused.com",
            "ora:category": "Java"
        ]
    }

    func testTwoElementsUnderDocumentElement() {
        let children = document.documentElement?.children(ofType: Element.self)
        expect(children?.count) == 2
        expect(children?.map({ $0.nodeName })) == ["JavaXML:Title", "JavaXML:Contents"]
    }

    func testFourChapterElements() {
        let chapterNodes = document.evaluate(path:
            ["JavaXML:Book", "JavaXML:Contents", "JavaXML:Chapter"])
        expect(chapterNodes.count) == 4

        let headingTextValues = chapterNodes.flatMap { (chapterNode) -> String? in
            let textNodes = chapterNode.evaluate(path: ["JavaXML:Heading", "#text"])
            return textNodes.first(ofType: Text.self)?.text
        }
        expect(headingTextValues.count) == 4

        expect(headingTextValues) == [
            "Introduction",
            "Creating XML",
            "Parsing XML",
            "Web Publishing Frameworks"
        ]
    }

    func testLastChild() {
        let de = document.documentElement
        let last = de?.lastChild
        expect(last).notTo(beNil())
        expect(last?.nodeName) == "JavaXML:Contents"

        let lastElement = last as? Element
        expect(lastElement?.attributes) == ["xmlns:topic": "http://www.oreilly.com/topics"]
    }
}
