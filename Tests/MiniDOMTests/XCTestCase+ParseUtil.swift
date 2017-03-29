//
//  XCTestCase+ParseUtil.swift
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
import XCTest

extension XCTestCase {
    func loadXML(resourceWithName name: String, extension ext: String) -> Document? {
        guard let url = Bundle(for: type(of: self)).url(forResource: name, withExtension: ext),
              let parser = Parser(contentsOf: url)
        else {
            XCTFail("Could not create parser")
            return nil
        }

        return parse(with: parser)
    }

    func loadXML(string: String) -> Document? {
        guard let parser = Parser(string: string) else {
            XCTFail("Could not create parser")
            return nil
        }

        return parse(with: parser)
    }

    private func parse(with parser: Parser) -> Document? {
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
