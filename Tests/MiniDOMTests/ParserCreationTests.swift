//
//  ParserCreationTests.swift
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
import Nimble
import XCTest

@testable import MiniDOM

class ParserCreationTests: XCTestCase {

    let source = [
        "<?xml version=\"1.0\" encoding=\"UTF-8\"?>",
        "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.1//EN\"",
        "    \"http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd\">",
        "<html version=\"-//W3C//DTD XHTML 1.1//EN\"",
        "      xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"en\"",
        "      xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"",
        "      xsi:schemaLocation=\"http://www.w3.org/1999/xhtml",
        "                          http://www.w3.org/MarkUp/SCHEMA/xhtml11.xsd\"",
        ">",
        "  <head>",
        "    <title>Virtual Library</title>",
        "  </head>",
        "  <body>",
        "    <p>Moved to <a href=\"http://example.org/\">example.org</a>.</p>",
        "  </body>",
        "</html>"
    ].joined(separator: "\n")

    func validateResults(from parser: Parser?) {
        expect(parser).notTo(beNil())

        let result = parser?.parse()
        expect(result).notTo(beNil())
        expect(result?.error).to(beNil())

        let document = result?.value
        expect(document).notTo(beNil())
    }

    func testParseString() {
        let parser = Parser(string: source)
        validateResults(from: parser)
    }

    func testParseFromURLAndInputStream() {
        let fileName = String(format: "%@_%@", ProcessInfo.processInfo.globallyUniqueString, "test-data.xml")
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        expect { try self.source.write(to: fileURL, atomically: true, encoding: .utf8) }.notTo(throwError())

        let urlParser = Parser(contentsOf: fileURL)
        validateResults(from: urlParser)

        guard let inputStream = InputStream(url: fileURL) else {
            fail("Cannot create input stream")
            return
        }

        let inputStreamParser = Parser(stream: inputStream)
        validateResults(from: inputStreamParser)
    }

    func testCreateWithNilData() {
        let parser = Parser(data: nil)
        expect(parser).to(beNil())
    }

    func testCreateWithNilParser() {
        let parser = Parser(parser: nil)
        expect(parser).to(beNil())
    }
}
