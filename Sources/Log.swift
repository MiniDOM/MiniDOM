//
//  Log.swift
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
    func verbose(_ message: String, file: String = #file, line: UInt = #line, function: String = #function) -> Bool {
        return log(.verbose, message, file: file, line: line, function: function)
    }

    @discardableResult
    func debug(_ message: String, file: String = #file, line: UInt = #line, function: String = #function) -> Bool {
        return log(.debug, message, file: file, line: line, function: function)
    }

    @discardableResult
    func info(_ message: String, file: String = #file, line: UInt = #line, function: String = #function) -> Bool {
        return log(.info, message, file: file, line: line, function: function)
    }

    @discardableResult
    func warn(_ message: String, file: String = #file, line: UInt = #line, function: String = #function) -> Bool {
        return log(.warn, message, file: file, line: line, function: function)
    }

    @discardableResult
    func error(_ message: String, file: String = #file, line: UInt = #line, function: String = #function) -> Bool {
        return log(.error, message, file: file, line: line, function: function)
    }

    @discardableResult
    func error(_ error: Error, file: String = #file, line: UInt = #line, function: String = #function) -> Bool {
        return self.error(error.localizedDescription, file: file, line: line, function: function)
    }

    @discardableResult
    func log(_ level: Level, _ message: String, file: String = #file, line: UInt = #line, function: String = #function) -> Bool {
        guard level.rawValue >= self.level.rawValue else {
            return false
        }

        let filename = (file as NSString).lastPathComponent
        let level = String(describing: level).uppercased()
        print("[\(level)] (\(filename):\(line) \(function)) \(message)")
        return true
    }
}
