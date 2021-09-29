//
//  Formatter.swift
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

class Formatter {
    var xmlPrologue: String {
        return "<?xml version=\"1.0\" encoding=\"utf-8\"?>"
    }

    func formatStart(_ element: Element) -> String {
        let tagName = element.tagName.escapedString()
        let isLeaf = !element.hasChildren
        let slashIfLeaf = isLeaf ? "/" : ""

        if let attrs = formatAttributes(of: element) {
            return "<\(tagName) \(attrs)\(slashIfLeaf)>"
        }

        return "<\(tagName)\(slashIfLeaf)>"
    }

    func formatEnd(_ element: Element) -> String? {
        if element.hasChildren {
            return "</\(element.tagName.escapedString())>"
        }

        return nil
    }

    func formatAttributes(of element: Element) -> String? {
        guard let attrs = element.attributes, !attrs.isEmpty else {
            return nil
        }

        var formatted: [String] = []
        let sortedAttributes = attrs.sorted { (kv1: (String, String), kv2: (String, String)) -> Bool in
            return kv1.0 < kv2.0
        }

        for (key, value) in sortedAttributes {
            formatted.append("\(key.escapedString())=\"\(value.escapedString())\"")
        }

        return formatted.joined(separator: " ")
    }

    func format(_ processingInstruction: ProcessingInstruction) -> String {
        var parts: [String] = []

        parts.append(processingInstruction.target)
        if let data = processingInstruction.data {
            parts.append(data.escapedString(shouldEscapePredefinedEntities: false))
        }

        let body = parts.joined(separator: " ")
        return "<?\(body)?>"
    }

    func format(_ comment: Comment) -> String {
        return "<!--\(comment.text.escapedString(shouldEscapePredefinedEntities: false))-->"
    }

    func format(_ cdataSection: CDATASection) -> String {
        return "<![CDATA[\(cdataSection.text.escapedString(shouldEscapePredefinedEntities: false))]]>"
    }

    func format(_ text: Text, trim: Bool) -> String {
        let unescaped = trim ? text.text.trimmed : text.text
        return unescaped.escapedString()
    }
}

class PrettyPrinter: Formatter, Visitor {
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

    private(set) var formattedString: String?

    private let indentString: String

    init(indentWith string: String) {
        self.indentString = string
    }

    private func addLine(_ string: String?) {
        guard let string = string else {
            return
        }

        lines.append(Line(depth: depth, value: string))
    }

    public func beginVisit(_ document: Document) {
        addLine(xmlPrologue)
    }

    public func endVisit(_ document: Document) {
        formattedString = lines.map({ $0.format(indentingWith: indentString) }).joined(separator: "\n")
    }

    public func beginVisit(_ element: Element) {
        addLine(formatStart(element))
        depth += 1
    }

    public func endVisit(_ element: Element) {
        depth -= 1
        addLine(formatEnd(element))
    }

    public func visit(_ text: Text) {
        let formatted = format(text, trim: true)
        if formatted.isEmpty {
            return
        }
        addLine(formatted)
    }

    public func visit(_ processingInstruction: ProcessingInstruction) {
        addLine(format(processingInstruction))
    }

    public func visit(_ comment: Comment) {
        addLine(format(comment))
    }

    public func visit(_ cdataSection: CDATASection) {
        addLine(format(cdataSection))
    }
}

class TreeDumper: Formatter, Visitor {
    private var parts: [String] = []

    private(set) var formattedString: String?

    public func beginVisit(_ document: Document) {
        parts.append(xmlPrologue)
        parts.append("\n")
    }

    public func endVisit(_ document: Document) {
        formattedString = parts.joined()
    }

    public func beginVisit(_ element: Element) {
        parts.append(formatStart(element))
    }

    public func endVisit(_ element: Element) {
        if let part = formatEnd(element) {
            parts.append(part)
        }
    }

    public func visit(_ text: Text) {
        parts.append(format(text, trim: false))
    }

    public func visit(_ processingInstruction: ProcessingInstruction) {
        parts.append(format(processingInstruction))
    }

    public func visit(_ comment: Comment) {
        parts.append(format(comment))
    }

    public func visit(_ cdataSection: CDATASection) {
        parts.append(format(cdataSection))
    }
}

public extension Node {
    /**
     Generates a formatted XML string representation of this node and its
     descendants.

     - parameter indentWith: The string used to indent the formatted string.

     - returns: A formatted XML string representation of this node and its
     descendants.
     */
    func prettyPrint(indentWith: String = "\t") -> String? {
        let formatter = PrettyPrinter(indentWith: indentWith)
        accept(formatter)
        return formatter.formattedString
    }

    /**
     Generates an unformatted XML string representation of this node and its
     descendants.

     - returns: A formatted XML string representation of this node and its
     descendants.
     */
    func dump() -> String? {
        let formatter = TreeDumper()
        accept(formatter)
        return formatter.formattedString
    }
}
