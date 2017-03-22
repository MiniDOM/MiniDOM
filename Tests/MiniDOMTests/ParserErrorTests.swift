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
import MiniDOM
import Nimble
import XCTest

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
        expect(parser).notTo(beNil())

        let result = parser?.parse()
        expect(result).notTo(beNil())
        expect(result?.value).to(beNil())
        expect(result?.error).notTo(beNil())
        // TODO: verify actual error
    }

    func testExtraCloseTags() {
        let source = [
            "<?xml version=\"1.0\" encoding=\"utf-8\"?>",
            "<foo>",
            "  <bar></bar></bar>",
            "</foo>"
            ].joined(separator: "\n")

        let parser = Parser(string: source)
        expect(parser).notTo(beNil())

        let result = parser?.parse()
        expect(result).notTo(beNil())
        expect(result?.value).to(beNil())
        expect(result?.error).notTo(beNil())
        // TODO: verify actual error
    }
}
