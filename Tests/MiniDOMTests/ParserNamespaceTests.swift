//
//  ParserNamespaceTests.swift
//  MiniDOM
//
//  Created by Paul Calnan on 3/26/17.
//  Copyright © 2017 Anodized Software, Inc. All rights reserved.
//

import Foundation
import MiniDOM
import Nimble
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
        expect(result?.isSuccess).to(beTrue())

        let document = result?.value

        let cvslog = document?.documentElement
        expect(cvslog).notTo(beNil())
        expect(cvslog?.tagName) == "cvslog"
        expect(cvslog?.attributes) == ["xmlns": "http://xml.apple.com/cvslog"]
        expect(cvslog?.children.count) == 1

        let radar = cvslog?.firstChild
        expect(radar).notTo(beNil())
        expect(radar?.nodeName) == "radar:radar"
        expect(radar?.attributes) == ["xmlns:radar": "http://xml.apple.com/radar"]
        expect(radar?.children.count) == 2

        let bugID = radar?.firstChild
        expect(bugID).notTo(beNil())
        expect(bugID?.nodeName) == "radar:bugID"
        expect(bugID?.children.count) == 1

        let bugIdText = bugID?.firstChild
        expect(bugIdText).notTo(beNil())
        expect(bugIdText?.nodeType) == .text
        expect(bugIdText?.nodeValue) == "2920186"

        let title = radar?.lastChild
        expect(title).notTo(beNil())
        expect(title?.nodeName) == "radar:title"
        expect(title?.children.count) == 1

        let titleText = title?.firstChild
        expect(titleText).notTo(beNil())
        expect(titleText?.nodeType) == .text
        expect(titleText?.nodeValue) == "API/NSXMLParser: there ought to be an NSXMLParser"

        let formatted = document?.format(indentWith: "  ")
        expect(formatted) == [
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
        ].joined(separator: "\n")
    }
}
