//
//  ParserPlistTests.swift
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
