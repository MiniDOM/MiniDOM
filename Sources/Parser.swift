//
//  Parser.swift
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

public enum Result<SuccessType> {
    case success(SuccessType)
    case failure(Error)

    public var value: SuccessType? {
        if case let .success(value) = self {
            return value
        }

        return nil
    }

    public var error: Error? {
        if case let .failure(error) = self {
            return error
        }

        return nil
    }
}

public class Parser {
    private let parser: XMLParser

    private let log = Log(level: .all)

    public enum Error: Swift.Error {
        case invalidXML
        case unspecifiedError
    }

    public convenience init?(contentsOf url: URL) {
        guard let parser = XMLParser(contentsOf: url) else {
            return nil
        }

        self.init(parser: parser)
    }

    public convenience init?(string: String, encoding: String.Encoding = .utf8) {
        guard let data = string.data(using: encoding) else {
            return nil
        }

        self.init(data: data)
    }

    public convenience init(data: Data) {
        self.init(parser: XMLParser(data: data))
    }

    public convenience init(stream: InputStream) {
        self.init(parser: XMLParser(stream: stream))
    }

    private init(parser: XMLParser) {
        self.parser = parser
    }

    public func parse() -> Result<Document> {
        let stack = NodeStack()
        parser.delegate = stack

        guard parser.parse(), let document = stack.document else {
            let error = parser.parserError ?? Error.unspecifiedError
            log.error("Error parsing document: \(error)")
            return .failure(error)
        }

        parser.delegate = nil
        return .success(document)
    }
}

fileprivate class NodeStack: NSObject, XMLParserDelegate {
    private let log = Log(level: .warn)

    private var stack: ArraySlice<Node> = []

    private func popAndAppendToTopOfStack() {
        if let child = stack.popLast() {
            appendToTopOfStack(child: child)
        }
    }

    private func appendToTopOfStack(child: Node) {
        if var node = stack.popLast() {
            node.append(child: child)
            stack.append(node)
        }
    }

    var document: Document? {
        return stack.first as? Document
    }

    func parserDidStartDocument(_ parser: XMLParser) {
        log.debug("")
        stack.append(Document())
    }

    func parserDidEndDocument(_ parser: XMLParser) {
        log.debug("")
        // no-op; leave top of stack for caller
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        log.debug("elementName=\(elementName) namespaceURI=\(namespaceURI) qualifiedName=\(qName), attributes=\(attributeDict)")
        stack.append(Element(tagName: elementName, namespaceURI: namespaceURI, qualifiedName: qName, attributes: attributeDict))
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        log.debug("elementName=\(elementName) namespaceURI=\(namespaceURI) qualifiedName=\(qName)")
        popAndAppendToTopOfStack()
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let trimmed = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return
        }

        log.debug("string=\(trimmed)")
        let text = Text(text: trimmed)
        appendToTopOfStack(child: text)
    }

    func parser(_ parser: XMLParser, foundProcessingInstructionWithTarget target: String, data: String?) {
        log.debug("target=\(target) data=\(data)")
        let pi = ProcessingInstruction(target: target, data: data)
        appendToTopOfStack(child: pi)
    }

    func parser(_ parser: XMLParser, foundComment comment: String) {
        log.debug("comment=\(comment)")
        let comment = Comment(text: comment)
        appendToTopOfStack(child: comment)
    }

    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        log.debug("CDATABlock=\(CDATABlock)")
        guard let text = String(data: CDATABlock, encoding: .utf8) else {
            log.error("invalid encoding")
            parser.abortParsing()
            return
        }
        
        let cdata = CDATASection(text: text)
        appendToTopOfStack(child: cdata)
    }
}
