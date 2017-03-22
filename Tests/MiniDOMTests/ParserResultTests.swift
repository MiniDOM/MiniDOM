//
//  ParserResultTests.swift
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

class ParserResultTests: XCTestCase {
    func testSuccess() {
        let result: Result<Int> = .success(42)
        expect(result.error).to(beNil())
        expect(result.value).notTo(beNil())
        expect(result.value) == 42
    }

    func testFailure() {
        let error = NSError(domain: "anErrorDomain", code: 123456, userInfo: nil)
        let result: Result<Int> = .failure(error)
        expect(result.value).to(beNil())
        expect(result.error).notTo(beNil())
        expect(result.error) === error
    }
}
