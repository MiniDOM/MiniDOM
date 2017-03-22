//
//  ParserPlistTests.swift
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

class ParserPlistTests: XCTestCase {
    var source: String!

    var document: Document!
    
    override func setUp() {
        super.setUp()

        let source = [
            "<?xml version=\"1.0\" encoding=\"UTF-8\"?>",
            "<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">",
            "<plist version=\"1.0\">",
            "<dict>",
            "<key>CFBundleDevelopmentRegion</key>",
            "<string>en</string>",
            "<key>CFBundleExecutable</key>",
            "<string>$(EXECUTABLE_NAME)</string>",
            "<key>CFBundleIdentifier</key>",
            "<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>",
            "<key>CFBundleInfoDictionaryVersion</key>",
            "<string>6.0</string>",
            "<key>CFBundleName</key>",
            "<string>$(PRODUCT_NAME)</string>",
            "<key>CFBundlePackageType</key>",
            "<string>BNDL</string>",
            "<key>CFBundleShortVersionString</key>",
            "<string>1.0</string>",
            "<key>CFBundleVersion</key>",
            "<string>1</string>",
            "</dict>",
            "</plist>",
        ].joined(separator: "\n")

        document = loadXML(string: source)
    }

    func testRootElement() {
        let documentElement = document.documentElement

        expect(documentElement).notTo(beNil())
        expect(documentElement?.nodeName) == "plist"
        expect(documentElement?.attributes) == [
            "version": "1.0"
        ]
    }

    func testSingleDictElementUnderRoot() {
        let documentElement = document.documentElement

        expect(documentElement?.children.count) == 1

        let dict = documentElement?.firstChild
        expect(dict).notTo(beNil())
        expect(dict?.nodeName) == "dict"
        expect(dict?.children.count) == 16
    }

    func testDictElementIsCorrect() {
        let dict = document.documentElement?.firstChild

        let expectedNodeNames: [String] = [
            "key",
            "string",
            "key",
            "string",
            "key",
            "string",
            "key",
            "string",
            "key",
            "string",
            "key",
            "string",
            "key",
            "string",
            "key",
            "string",
        ]
        let actualNodeNames: [String] = dict?.children.map { $0.nodeName } ?? []
        expect(expectedNodeNames) == actualNodeNames

        let expectedNodeValues: [String] = [
            "CFBundleDevelopmentRegion",
            "en",
            "CFBundleExecutable",
            "$(EXECUTABLE_NAME)",
            "CFBundleIdentifier",
            "$(PRODUCT_BUNDLE_IDENTIFIER)",
            "CFBundleInfoDictionaryVersion",
            "6.0",
            "CFBundleName",
            "$(PRODUCT_NAME)",
            "CFBundlePackageType",
            "BNDL",
            "CFBundleShortVersionString",
            "1.0",
            "CFBundleVersion",
            "1",
        ]

        let actualNodeValues: [String] = dict?.children.flatMap { $0.firstChild?.nodeValue } ?? []
        expect(expectedNodeValues) == actualNodeValues
    }
}
