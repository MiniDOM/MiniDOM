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

public protocol Formatter {

    var prologue: String { get }

    func formatStart(_ element: Element) -> String
    func formatEnd(_ element: Element) -> String?
    func formatAttributes(of element: Element) -> String?
    func format(_ processingInstruction: ProcessingInstruction) -> String
    func format(_ comment: Comment) -> String
    func format(_ text: Text, trim: Bool) -> String
    func format(_ cdataSection: CDATASection) -> String
}

public class XMLFormatter: Formatter {

    public enum Encoding: String {
        case utf8 = "utf-8"
        case latin1 = "iso-8859-1"
    }

    public let encoding: Encoding

    public var prologue: String {
        return "<?xml version=\"1.0\" encoding=\"\(encoding.rawValue)\"?>"
    }

    public init(encoding: Encoding) {
        self.encoding = encoding
    }

    public func formatStart(_ element: Element) -> String {
        let tagName = element.tagName.escapedString()
        let isLeaf = !element.hasChildren
        let slashIfLeaf = isLeaf ? "/" : ""

        if let attrs = formatAttributes(of: element) {
            return "<\(tagName) \(attrs)\(slashIfLeaf)>"
        }

        return "<\(tagName)\(slashIfLeaf)>"
    }

    public func formatEnd(_ element: Element) -> String? {
        if element.hasChildren {
            return "</\(element.tagName.escapedString())>"
        }

        return nil
    }

    public func formatAttributes(of element: Element) -> String? {
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

    public func format(_ processingInstruction: ProcessingInstruction) -> String {
        var parts: [String] = []

        parts.append(processingInstruction.target)
        if let data = processingInstruction.data {
            parts.append(data.escapedString(shouldEscapePredefinedEntities: false))
        }

        let body = parts.joined(separator: " ")
        return "<?\(body)?>"
    }

    public func format(_ comment: Comment) -> String {
        return "<!--\(comment.text.escapedString(shouldEscapePredefinedEntities: false))-->"
    }

    public func format(_ cdataSection: CDATASection) -> String {
        return "<![CDATA[\(cdataSection.text.escapedString(shouldEscapePredefinedEntities: false))]]>"
    }

    public func format(_ text: Text, trim: Bool) -> String {
        let unescaped = trim ? text.text.trimmed : text.text
        return unescaped.escapedString()
    }
}

class PrettyPrinter: Visitor {

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

    let formatter: Formatter

    var formattedString: String {
        return lines.map({ $0.format(indentingWith: indentString) }).joined(separator: "\n")
    }

    private var depth = 0
    private var lines: [Line] = []
    private let indentString: String

    init(formatter: Formatter, indentString: String) {
        self.formatter = formatter
        self.indentString = indentString
    }

    func beginVisit(_ document: Document) {
        addLine(formatter.prologue)
    }

    public func beginVisit(_ element: Element) {
        addLine(formatter.formatStart(element))
        depth += 1
    }

    func endVisit(_ element: Element) {
        depth -= 1
        addLine(formatter.formatEnd(element))
    }

    func visit(_ text: Text) {
        let formatted = formatter.format(text, trim: true)
        if formatted.isEmpty {
            return
        }
        addLine(formatted)
    }

    func visit(_ processingInstruction: ProcessingInstruction) {
        addLine(formatter.format(processingInstruction))
    }

    func visit(_ comment: Comment) {
        addLine(formatter.format(comment))
    }

    func visit(_ cdataSection: CDATASection) {
        addLine(formatter.format(cdataSection))
    }

    private func addLine(_ string: String?) {
        guard let string = string, !string.isEmpty else {
            return
        }
        lines.append(Line(depth: depth, value: string))
    }
}

class TreeDumper: Visitor {

    let formatter: Formatter

    var formattedString: String {
        return parts.joined()
    }

    private var parts: [String] = []

    init(formatter: Formatter) {
        self.formatter = formatter
    }

    func beginVisit(_ document: Document) {
        parts.append(formatter.prologue)
        parts.append("\n")
    }

    func beginVisit(_ element: Element) {
        parts.append(formatter.formatStart(element))
    }

    func endVisit(_ element: Element) {
        if let part = formatter.formatEnd(element) {
            parts.append(part)
        }
    }

    func visit(_ text: Text) {
        parts.append(formatter.format(text, trim: false))
    }

    func visit(_ processingInstruction: ProcessingInstruction) {
        parts.append(formatter.format(processingInstruction))
    }

    func visit(_ comment: Comment) {
        parts.append(formatter.format(comment))
    }

    func visit(_ cdataSection: CDATASection) {
        parts.append(formatter.format(cdataSection))
    }
}

public extension Node {
    /**
     Generates a formatted XML string representation of this node and its
     descendants.

     - parameter indentWith: The string used to indent the formatted string.
     - parameter encoding: The encoding to use in the resulting XML string.

     - returns: A formatted XML string representation of this node and its
     descendants.
     */
    func prettyPrint(indentWith indentString: String = "\t", encoding: XMLFormatter.Encoding = .utf8) -> String {
        return prettyPrint(using: XMLFormatter(encoding: encoding), indentWith: indentString)
    }

    /**
     Generates a formatted string representation of this node and its
     descendants using the given formatter.

     - parameter formatter: The formatter to use while traversing the tree.
     - parameter indentWith: The string used to indent the formatted string.

     - returns: A formatted string representation of this node and its
     descendants.
     */
    func prettyPrint(using formatter: Formatter, indentWith indentString: String = "\t") -> String {
        let printer = PrettyPrinter(formatter: formatter, indentString: indentString)
        accept(printer)
        return printer.formattedString
    }

    /**
     Generates an unformatted XML string representation of this node and its
     descendants.

     - parameter encoding: The encoding to use in the resulting XML string.

     - returns: An unformatted XML string representation of this node and its
     descendants.
     */
    func dump(encoding: XMLFormatter.Encoding = .utf8) -> String {
        return dump(using: XMLFormatter(encoding: encoding))
    }

    /**
     Generates an unformatted string representation of this node and its
     descendants using the given formatter.

     - parameter formatter: The formatter to use while traversing the tree.

     - returns: An unformatted string representation of this node and its
     descendants.
     */
    func dump(using formatter: Formatter) -> String {
        let dumper = TreeDumper(formatter: formatter)
        accept(dumper)
        return dumper.formattedString
    }
}
