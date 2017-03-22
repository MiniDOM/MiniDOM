//
//  RSSTests.swift
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

class RSSTests: XCTestCase {
    var document: Document!
    
    override func setUp() {
        super.setUp()
        document = loadXML(string: yahooTestsSource)
    }

    func testCdataInTitle() {
        let titleNode = document.evaluate(path: ["rss", "channel", "title", "#cdata-section"]).first
        expect(titleNode).notTo(beNil())
        expect(titleNode?.nodeType) == .cdataSection

        let titleCdata = titleNode as? CDATASection
        expect(titleCdata).notTo(beNil())
        expect(titleCdata?.text) == "Yahoo! News Search Results for market"
    }
}
