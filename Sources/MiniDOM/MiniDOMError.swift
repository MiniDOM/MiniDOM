//
//  MiniDOMError.swift
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

/**
 Used to represent an error from the MiniDOM library.
 */
public enum MiniDOMError: Error, Equatable {

    /**
     Indicates that the parser terminated abnormally resulting in the
     associated error value
     */
    case xmlParserError(Error)

    /**
     Indicates that the parser terminated abnormally but did not report an
     error.
     */
    case unspecifiedError

    /**
     Converts a raw error as provided by `XMLParser.parserError` into a
     `MiniDOMError`.
     */
    internal static func from(_ parserError: Error?) -> MiniDOMError {
        guard let e = parserError else {
            return .unspecifiedError
        }
        return .xmlParserError(e)
    }

    public static func == (lhs: MiniDOMError, rhs: MiniDOMError) -> Bool {
        switch (lhs, rhs) {
        case (.unspecifiedError, .unspecifiedError):
            return true

        case (.xmlParserError(let e1), .xmlParserError(let e2)):
            return (e1 as NSError) == (e2 as NSError)

        default:
            return false
        }
    }
}
