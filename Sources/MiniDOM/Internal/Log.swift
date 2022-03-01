//
//  Log.swift
//  MiniDOM
//
//  Copyright 2017-2021 Anodized Software, Inc.
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

struct Log {
    enum Level: Int {
        case all
        case verbose
        case debug
        case info
        case warn
        case error
        case off
    }

    let level: Level

    @discardableResult
    func verbose(_ message: @autoclosure () -> String, file: String = #file, line: UInt = #line, function: String = #function) -> Bool {
        return log(.verbose, message, file: file, line: line, function: function)
    }

    @discardableResult
    func debug(_ message: @autoclosure () -> String, file: String = #file, line: UInt = #line, function: String = #function) -> Bool {
        return log(.debug, message, file: file, line: line, function: function)
    }

    @discardableResult
    func info(_ message: @autoclosure () -> String, file: String = #file, line: UInt = #line, function: String = #function) -> Bool {
        return log(.info, message, file: file, line: line, function: function)
    }

    @discardableResult
    func warn(_ message: @autoclosure () -> String, file: String = #file, line: UInt = #line, function: String = #function) -> Bool {
        return log(.warn, message, file: file, line: line, function: function)
    }

    @discardableResult
    func error(_ message: @autoclosure () -> String, file: String = #file, line: UInt = #line, function: String = #function) -> Bool {
        return log(.error, message, file: file, line: line, function: function)
    }

    @discardableResult
    func error(_ error: @autoclosure () -> Error, file: String = #file, line: UInt = #line, function: String = #function) -> Bool {
        return self.error(error().localizedDescription, file: file, line: line, function: function)
    }

    @discardableResult
    func log(_ level: Level, _ message: () -> String, file: String = #file, line: UInt = #line, function: String = #function) -> Bool {
        guard level.rawValue >= self.level.rawValue else {
            return false
        }

        let filename = (file as NSString).lastPathComponent
        let level = String(describing: level).uppercased()
        print("[\(level)] (\(filename):\(line) \(function)) \(message())")
        return true
    }
}
