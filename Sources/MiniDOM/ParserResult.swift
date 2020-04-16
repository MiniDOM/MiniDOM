//
//  ParserResult.swift
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

/// Encapsulates the result of a parser operation.
public typealias ParserResult = Result<Document, MiniDOMError>

/// Convenience functions for parser results.
public extension ParserResult {

    /// Returns `true` if the result is a success, `false` otherwise.
    var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }

    /// Returns `true` if the result is a failure, `false` otherwise.
    var isFailure: Bool {
        return !isSuccess
    }

    /**
     Returns the assoicated value if the result is a success, `nil` otherwise.
     */
    var document: Document? {
        if case let .success(doc) = self {
            return doc
        }

        return nil
    }

    /**
     Returns the associated error value if the result is a failure, `nil`
     otherwise.
     */
    var error: MiniDOMError? {
        if case let .failure(error) = self {
            return error
        }

        return nil
    }
}
