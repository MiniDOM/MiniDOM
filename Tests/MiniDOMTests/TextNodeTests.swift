//
//  TextNodeTests.swift
//  MiniDOM
//
//  Created by Paul Calnan on 3/30/17.
//  Copyright © 2017 Anodized Software, Inc. All rights reserved.
//

import Foundation
import MiniDOM
import XCTest

class TextNodeTests: XCTestCase {

    var source: String!

    var document: Document!
    
    override func setUp() {
        super.setUp()

        source = [
            "<feed>",
            "<item>",
            "<title>California Bill To Ban “Fake News” Would Be Disastrous for Political Speech</title>",
            "</item>",
            "<item>",
            "<title>Small ISPs Oppose Congress&#039;s Move to Abolish Privacy Protections</title>",
            "</item>",
            "</feed>"
        ].joined(separator: "\n")

        document = loadXML(string: source)
    }

    func testFirstTitle() {
        let title = document.elements(withTagName: "title").first
        XCTAssertNotNil(title)

        let titleTextNodes = title?.children(ofType: Text.self)
        XCTAssertNotNil(titleTextNodes)
        XCTAssertEqual(titleTextNodes?.count, 2)
        XCTAssertEqual(titleTextNodes?.flatMap({ $0.nodeValue }) ?? [],
                       ["California Bill To Ban ", "“Fake News” Would Be Disastrous for Political Speech"])
    }
}
