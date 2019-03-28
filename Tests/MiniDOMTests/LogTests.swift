//
//  LogTests.swift
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

class LogTests: XCTestCase {
    func check(log: Log, expectError: Bool, expectWarn: Bool, expectInfo: Bool, expectDebug: Bool, expectVerbose: Bool, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(log.error("Error"), expectError, file: file, line: line)
        XCTAssertEqual(log.error(NSError.init(domain: "anErrorDomain", code: 123456, userInfo: nil)), expectError, file: file, line: line)
        XCTAssertEqual(log.warn("Warn"), expectWarn, file: file, line: line)
        XCTAssertEqual(log.info("Info"),  expectInfo, file: file, line: line)
        XCTAssertEqual(log.debug("Debug"), expectDebug, file: file, line: line)
        XCTAssertEqual(log.verbose("Verbose"), expectVerbose, file: file, line: line)
    }

    func testLogLevels() {
        check(log: Log(level: .all),     expectError: true,  expectWarn: true,  expectInfo: true,  expectDebug: true,  expectVerbose: true)
        check(log: Log(level: .verbose), expectError: true,  expectWarn: true,  expectInfo: true,  expectDebug: true,  expectVerbose: true)
        check(log: Log(level: .debug),   expectError: true,  expectWarn: true,  expectInfo: true,  expectDebug: true,  expectVerbose: false)
        check(log: Log(level: .info),    expectError: true,  expectWarn: true,  expectInfo: true,  expectDebug: false, expectVerbose: false)
        check(log: Log(level: .warn),    expectError: true,  expectWarn: true,  expectInfo: false, expectDebug: false, expectVerbose: false)
        check(log: Log(level: .error),   expectError: true,  expectWarn: false, expectInfo: false, expectDebug: false, expectVerbose: false)
        check(log: Log(level: .off),     expectError: false, expectWarn: false, expectInfo: false, expectDebug: false, expectVerbose: false)
    }
}
