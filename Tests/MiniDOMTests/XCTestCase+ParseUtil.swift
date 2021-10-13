//
//  XCTestCase+ParseUtil.swift
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
import MiniDOM
import XCTest

extension XCTestCase {
    func loadXML(resourceWithName name: String, extension ext: String) -> Document? {
        guard let url = Bundle(for: type(of: self)).url(forResource: name, withExtension: ext),
              let parser = DOMParser(contentsOf: url)
        else {
            XCTFail("Could not create parser")
            return nil
        }

        return parse(with: parser)
    }

    func loadXML(string: String) -> Document? {
        guard let parser = DOMParser(string: string) else {
            XCTFail("Could not create parser")
            return nil
        }

        return parse(with: parser)
    }

    private func parse(with parser: DOMParser) -> Document? {
        let result = parser.parse()
        switch result {
        case let .success(d):
            return d

        case let .failure(error):
            XCTFail("Error parsing: \(error)")
            return nil
        }
    }
}
