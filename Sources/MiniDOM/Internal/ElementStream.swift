//
//  ElementStream.swift
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

class ElementStream: SAXConsumer {

    let callback: (Element) throws -> Bool
    let filter: (String) -> Bool

    private(set) var continueParsing = true

    private let log = Log(level: .warn)
    private var stacks: ArraySlice<NodeStack> = []

    init(callback: @escaping (Element) throws -> Bool, filter: @escaping (String) -> Bool) {
        self.callback = callback
        self.filter = filter
    }

    func didStartDocument() {
        // no-op
    }

    func didEndDocument() {
        // no-op
    }

    func didStart(elementName: String, attributes: [String: String]) {
        guard continueParsing else {
            return
        }

        log.debug("start elementName=\(elementName) attributes=\(attributes)")

        if filter(elementName) {
            stacks.append(NodeStack())
        }

        do {
            try stacks.last?.append(node: Element(tagName: elementName, attributes: attributes))
        }
        catch {
            continueParsing = false
        }
    }

    func didEnd(elementName: String) {
        log.debug("end elementName=\(elementName)")

        autoreleasepool {
            do {
                try stacks.last?.popAndAppend()

                if filter(elementName),
                   let element = stacks.popLast()?.first as? Element {
                    if try !callback(element) {
                        continueParsing = false
                    }
                    try stacks.last?.append(node: element)
                    try stacks.last?.popAndAppend()
                }
            }
            catch {
                continueParsing = false
            }
        }
    }

    func foundCharacters(in string: String) {
        do {
            try stacks.last?.append(string: string, nodeType: Text.self)
        }
        catch {
            continueParsing = false
        }
    }

    func foundProcessingInstruction(target: String, data: String?) {
        log.debug("processing instruction target=\(target) data=\(String(describing: data))")
        do {
            try stacks.last?.append(node: ProcessingInstruction(target: target, data: data))
        }
        catch {
            continueParsing = false
        }
    }

    func foundComment(_ comment: String) {
        log.debug("comment=\(comment)")
        do {
            try stacks.last?.append(node: Comment(text: comment))
        }
        catch {
            continueParsing = false
        }
    }

    func foundCDATA(_ CDATAString: String) {
        log.debug("CDATA=\(CDATAString)")
        do {
            try stacks.last?.append(string: CDATAString, nodeType: CDATASection.self)
        }
        catch {
            continueParsing = false
        }
    }
}
