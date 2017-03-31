//
//  ParserNamespaceTests.swift
//  MiniDOM
//
//  Created by Paul Calnan on 3/26/17.
//  Copyright © 2017 Anodized Software, Inc. All rights reserved.
//

import Foundation
import MiniDOM
import XCTest

class ParserNamespaceTests: XCTestCase {

    var source: String!

    override func setUp() {
        super.setUp()

        source = [
            "<?xml version=\"1.0\" encoding=\"UTF-8\"?>",
            "<?xml-stylesheet type='text/css' href='cvslog.css'?>",
            "<!DOCTYPE cvslog SYSTEM \"cvslog.dtd\">",
            "<cvslog xmlns=\"http://xml.apple.com/cvslog\">",
            "  <radar:radar xmlns:radar=\"http://xml.apple.com/radar\">",
            "    <radar:bugID>2920186</radar:bugID>",
            "    <radar:title>API/NSXMLParser: there ought to be an NSXMLParser</radar:title>",
            "  </radar:radar>",
            "</cvslog>"
        ].joined(separator: "\n")
    }

    func testParseWithoutNamespacesOrEntities() {
        let parser = Parser(string: source)

        let result = parser?.parse()
        XCTAssertTrue(result?.isSuccess == true)

        var document = result?.value
        document?.normalize()

        let cvslog = document?.documentElement
        XCTAssertNotNil(cvslog)
        XCTAssertEqual(cvslog?.tagName, "cvslog")
        XCTAssertEqual(cvslog?.attributes ?? [:], ["xmlns": "http://xml.apple.com/cvslog"])
        XCTAssertEqual(cvslog?.childElements.count, 1)

        let radar = cvslog?.firstChildElement
        XCTAssertNotNil(radar)
        XCTAssertEqual(radar?.nodeName, "radar:radar")
        XCTAssertEqual(radar?.attributes ?? [:], ["xmlns:radar": "http://xml.apple.com/radar"])
        XCTAssertEqual(radar?.childElements.count, 2)

        let bugID = radar?.firstChildElement
        XCTAssertNotNil(bugID)
        XCTAssertEqual(bugID?.nodeName, "radar:bugID")
        XCTAssertEqual(bugID?.children.count, 1)

        let bugIdText = bugID?.firstChild
        XCTAssertNotNil(bugIdText)
        XCTAssertEqual(bugIdText?.nodeType, .text)
        XCTAssertEqual(bugIdText?.nodeValue, "2920186")

        let title = radar?.lastChildElement
        XCTAssertNotNil(title)
        XCTAssertEqual(title?.nodeName, "radar:title")
        XCTAssertEqual(title?.children.count, 1)

        let titleText = title?.firstChild
        XCTAssertNotNil(titleText)
        XCTAssertEqual(titleText?.nodeType, .text)
        XCTAssertEqual(titleText?.nodeValue, "API/NSXMLParser: there ought to be an NSXMLParser")

        let formatted = document?.prettyPrint(indentWith: "  ")
        print(formatted ?? "nil")
        XCTAssertEqual(formatted, [
            "<?xml version=\"1.0\" encoding=\"utf-8\"?>",
            "<?xml-stylesheet type='text/css' href='cvslog.css'?>",
            // The <!DOCTYPE> entity will be dropped as it is not handled
            "<cvslog xmlns=\"http://xml.apple.com/cvslog\">",
            "  <radar:radar xmlns:radar=\"http://xml.apple.com/radar\">",
            "    <radar:bugID>",
            "      2920186", // the formatter puts text nodes on a new line
            "    </radar:bugID>",
            "    <radar:title>",
            "      API/NSXMLParser: there ought to be an NSXMLParser",
            "    </radar:title>",
            "  </radar:radar>",
            "</cvslog>"
        ].joined(separator: "\n"))
    }
}
