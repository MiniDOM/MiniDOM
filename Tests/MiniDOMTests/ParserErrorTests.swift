//
//  ParserErrorTests.swift
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
import XCTest

@testable import MiniDOM

class ParserErrorTests: XCTestCase {
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
        XCTAssertNil(result?.value)
        XCTAssertNotNil(result?.error)

        XCTAssertEqual(result?.error as NSError?, NSError(domain: XMLParser.errorDomain, code: 111, userInfo: nil))
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
        XCTAssertNil(result?.value)
        XCTAssertNotNil(result?.error)

        XCTAssertEqual(result?.error as NSError?, NSError(domain: XMLParser.errorDomain, code: 111, userInfo: nil))
    }

    func testSuccessResult() {
        let document = Document()
        let result = Result.success(document)

        XCTAssertTrue(result.isSuccess)
        XCTAssertFalse(result.isFailure)
        XCTAssertTrue(result.value === document)
        XCTAssertNil(result.error)
    }

    func testFailureResult() {
        let error = NSError(domain: "domain", code: 123, userInfo: nil)
        let result = Result<Document>.failure(error)

        XCTAssertFalse(result.isSuccess)
        XCTAssertTrue(result.isFailure)
        XCTAssertNil(result.value)
        XCTAssertEqual(result.error as NSError?, error)
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

        let result = parser?.parse()
        XCTAssertNotNil(result)

        XCTAssertNil(result?.value)
        guard case .some(Parser.Error.unspecifiedError) = result?.error else {
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
}
