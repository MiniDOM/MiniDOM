//
//  TextNodeTests.swift
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
