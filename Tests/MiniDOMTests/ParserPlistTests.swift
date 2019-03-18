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
import XCTest

class ParserPlistTests: XCTestCase {
    var source: String!

    var document: Document!

    override func setUp() {
        super.setUp()

        source = [
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

        XCTAssertNotNil(documentElement)
        XCTAssertEqual(documentElement?.nodeName, "plist")
        XCTAssertEqual(documentElement?.attributes ?? [:], [
            "version": "1.0"
        ])
    }

    func testSingleDictElementUnderRoot() {
        let documentElement = document.documentElement

        XCTAssertEqual(documentElement?.childElements.count, 1)

        let dict = documentElement?.firstChildElement
        XCTAssertNotNil(dict)
        XCTAssertEqual(dict?.nodeName, "dict")
        XCTAssertEqual(dict?.childElements.count, 16)
    }

    func testDictElementIsCorrect() {
        let expectedElementNames: [String] = [
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

        let dict = document.documentElement?.firstChildElement
        let actualElementNames: [String] = dict?.childElements.map { $0.nodeName } ?? []
        XCTAssertEqual(expectedElementNames, actualElementNames)

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

        let actualNodeValues: [String] = dict?.children.compactMap { $0.firstChild?.nodeValue } ?? []
        XCTAssertEqual(expectedNodeValues, actualNodeValues)
    }
}
