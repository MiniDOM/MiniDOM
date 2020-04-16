//
//  MiniDOMErrorTests.swift
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
import XCTest

@testable import MiniDOM

class MiniDOMErrorTests: XCTestCase {
    func testInvalidProcessingInstruction() {
        let source = [
            "<?xml version=\"1.0\" encoding=\"utf-8\"?>",
            "<? target data ?>",
            "<foo>",
            "  <bar/>",
            "</foo>"
        ].joined(separator: "\n")

        let parser = Parser(string: source)
        XCTAssertNotNil(parser)

        let result = parser?.parse()
        XCTAssertNotNil(result)
        XCTAssertNil(result?.document)
        XCTAssertNotNil(result?.error)

        XCTAssertEqual(result?.error, MiniDOMError.xmlParserError(NSError(domain: XMLParser.errorDomain, code: 111, userInfo: nil)))
    }

    func testExtraCloseTags() {
        let source = [
            "<?xml version=\"1.0\" encoding=\"utf-8\"?>",
            "<foo>",
            "  <bar></bar></bar>",
            "</foo>"
            ].joined(separator: "\n")

        let parser = Parser(string: source)
        XCTAssertNotNil(parser)

        let result = parser?.parse()
        XCTAssertNotNil(result)
        XCTAssertNil(result?.document)
        XCTAssertNotNil(result?.error)

        XCTAssertEqual(result?.error, .xmlParserError(NSError(domain: XMLParser.errorDomain, code: 111, userInfo: nil)))
    }

    func testSuccessResult() {
        let document = Document()
        let result = ParserResult.success(document)

        XCTAssertTrue(result.isSuccess)
        XCTAssertFalse(result.isFailure)
        XCTAssertTrue(result.document === document)
        XCTAssertNil(result.error)
    }

    func testFailureResult() {
        let error = NSError(domain: "domain", code: 123, userInfo: nil)
        let result = ParserResult.failure(MiniDOMError.xmlParserError(error))

        XCTAssertFalse(result.isSuccess)
        XCTAssertTrue(result.isFailure)
        XCTAssertNil(result.document)
        XCTAssertEqual(result.error, .xmlParserError(error))
    }

    fileprivate class AbortDetectingXMLParser: XMLParser {
        var parsingAborted = false

        override func abortParsing() {
            parsingAborted = true
        }
    }

    func testInvalidCDATABlock() {
        let bytes: [UInt8] = [192]
        let invalidUTF8data = Data(bytes)

        let nodeStack = NodeStack()
        let xmlParser = AbortDetectingXMLParser()

        XCTAssertFalse(xmlParser.parsingAborted)
        nodeStack.parser(xmlParser, foundCDATA: invalidUTF8data)
        XCTAssertTrue(xmlParser.parsingAborted)
    }

    func testNilDocumentNoError() {
        class TestXMLParser: XMLParser {
            override func parse() -> Bool {
                return false
            }

            override var parserError: Error? {
                return nil
            }
        }

        let parser = Parser(parser: TestXMLParser())
        XCTAssertNotNil(parser)

        let result = parser.parse()
        XCTAssertNotNil(result)

        XCTAssertNil(result.document)
        guard case .some(MiniDOMError.unspecifiedError) = result.error else {
            XCTFail()
            return
        }
    }

    func testUnbalancedEndElements() {
        let xmlParser = AbortDetectingXMLParser()
        let nodeStack = NodeStack()

        XCTAssertFalse(xmlParser.parsingAborted)
        nodeStack.parser(xmlParser, didEndElement: "fnord", namespaceURI: nil, qualifiedName: nil)
        XCTAssertTrue(xmlParser.parsingAborted)
    }

    func testAppendToEmptyStack() {
        let xmlParser = AbortDetectingXMLParser()
        let nodeStack = NodeStack()

        XCTAssertFalse(xmlParser.parsingAborted)
        nodeStack.parser(xmlParser, foundComment: "fnord")
        XCTAssertTrue(xmlParser.parsingAborted)
    }

    func testEquality() {
        XCTAssertEqual(MiniDOMError.unspecifiedError, MiniDOMError.unspecifiedError)

        let e1 = NSError(domain: XMLParser.errorDomain, code: 1, userInfo: nil)
        let e2 = NSError(domain: XMLParser.errorDomain, code: 2, userInfo: nil)

        XCTAssertNotEqual(e1, e2)

        XCTAssertEqual(MiniDOMError.xmlParserError(e1), MiniDOMError.xmlParserError(e1))

        XCTAssertNotEqual(MiniDOMError.unspecifiedError, MiniDOMError.xmlParserError(e1))
        XCTAssertNotEqual(MiniDOMError.xmlParserError(e1), MiniDOMError.unspecifiedError)
        XCTAssertNotEqual(MiniDOMError.xmlParserError(e1), MiniDOMError.xmlParserError(e2))
    }
}
