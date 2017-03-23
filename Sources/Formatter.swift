//
//  Formatter.swift
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

class Formatter: Visitor {
    private struct Line {
        let depth: Int
        let value: String

        func format(indentingWith indentString: String) -> String {
            return "\(self.indentation(forDepth: depth, with: indentString))\(value)"
        }

        private func indentation(forDepth depth: Int, with indentString: String) -> String {
            return Array(repeatElement(indentString, count: depth)).joined(separator: "")
        }
    }

    private var depth = 0

    private var lines: [Line] = []

    private(set) public var formattedString: String?

    private let indentString: String

    init(indentWith string: String) {
        self.indentString = string
    }

    private func addLine(_ string: String) {
        lines.append(Line(depth: depth, value: string))
    }

    public func beginVisit(_ document: Document) {
        addLine("<?xml version=\"1.0\" encoding=\"utf-8\"?>")
    }

    public func endVisit(_ document: Document) {
        formattedString = lines.map({ $0.format(indentingWith: indentString) }).joined(separator: "\n")
    }


    public func beginVisit(_ element: Element) {
        let isLeaf = !element.hasChildren
        let slashIfLeaf = isLeaf ? "/" : ""

        if let attrs = formatAttributes(of: element) {
            addLine("<\(element.tagName) \(attrs)\(slashIfLeaf)>")
        }
        else {
            addLine("<\(element.tagName)\(slashIfLeaf)>")
        }
        depth += 1
    }

    public func endVisit(_ element: Element) {
        depth -= 1

        if element.hasChildren {
            addLine("</\(element.tagName)>")
        }
    }

    private func formatAttributes(of element: Element) -> String? {
        if element.attributes?.isEmpty == true {
            return nil
        }

        var formatted: [String] = []
        let sortedAttributes = element.attributes?.sorted { (kv1: (String, String), kv2: (String, String)) -> Bool in
            return kv1.0 < kv2.0
        }

        for (key, value) in sortedAttributes ?? [] {
            formatted.append("\(key)=\"\(value)\"")
        }

        return formatted.joined(separator: " ")
    }

    public func visit(_ text: Text) {
        addLine(text.text)
    }

    public func visit(_ processingInstruction: ProcessingInstruction) {
        var parts: [String] = []

        parts.append(processingInstruction.target)
        if let data = processingInstruction.data {
            parts.append(data)
        }

        let body = parts.joined(separator: " ")
        addLine("<?\(body)?>")
    }

    public func visit(_ comment: Comment) {
        addLine("<!--\(comment.text)-->")
    }

    public func visit(_ cdataSection: CDATASection) {
        addLine("<![CDATA[\(cdataSection.text)]]>")
    }
}

public extension Node {
    /**
     Generates and XML string representation of this node and its descendants.
     
     - parameter indentWith: The string used to indent the formatted string.
     
     - returns: A formatted XML string representation of this node and its 
     descendants.
     */
    public func format(indentWith: String = "\t") -> String? {
        let formatter = Formatter(indentWith: indentWith)
        accept(formatter)
        return formatter.formattedString
    }
}
