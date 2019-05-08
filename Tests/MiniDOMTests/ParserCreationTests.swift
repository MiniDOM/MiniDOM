//
//  ParserCreationTests.swift
//  MiniDOM
//
//  Copyright 2017-2019 Anodized Software, Inc.
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
        XCTAssertNotNil(parser)

        let result = parser?.parse()
        XCTAssertNotNil(result)
        XCTAssertNil(result?.error)

        let document = result?.document
        XCTAssertNotNil(document)
    }

    func testParseString() {
        let parser = Parser(string: source)
        validateResults(from: parser)
    }

    func testParseFromURLAndInputStream() {
        let fileName = String(format: "%@_%@", ProcessInfo.processInfo.globallyUniqueString, "test-data.xml")
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)

        XCTAssertNoThrow(try self.source.write(to: fileURL, atomically: true, encoding: .utf8))

        let urlParser = Parser(contentsOf: fileURL)
        validateResults(from: urlParser)

        guard let inputStream = InputStream(url: fileURL) else {
            XCTFail("Cannot create input stream")
            return
        }

        let inputStreamParser = Parser(stream: inputStream)
        validateResults(from: inputStreamParser)
    }

    func testCreateWithNilData() {
        let parser = Parser(data: nil)
        XCTAssertNil(parser)
    }

    func testCreateWithNilParser() {
        let parser = Parser(parser: nil)
        XCTAssertNil(parser)
    }
}
