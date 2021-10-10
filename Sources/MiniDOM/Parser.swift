//
//  Parser.swift
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
 Instances of this class parse XML documents into a tree of DOM objects.
 */
public class Parser {

    private let parser: XMLParser

    private let log = Log(level: .all)

    /**
     Initializes a parser with the XML content referenced by the given URL.

     - parameter url: A `URL` object specifying a URL. The URL must be fully
     qualified and refer to a scheme that is supported by the `URL` type.

     - returns: An initialized `Parser` object or `nil` if an error occurs.
     */
    public convenience init?(contentsOf url: URL) {
        self.init(parser: XMLParser(contentsOf: url))
    }

    /**
     Initializes a parser with the XML contents encapsulated in a given string
     object.

     - parameter string: A `String` object containing XML markup.

     - parameter encoding: The encoding of the `String` object.

     - returns: An initialized `Parser` object or `nil` if an error occurs.
     */
    public convenience init?(string: String, encoding: String.Encoding = .utf8) {
        self.init(data: string.data(using: encoding))
    }

    /**
     Initializes a parser with the XML contents encapsulated in a given data
     object.

     - parameter data: A `Data` object containing XML markup.

     - returns: An initialized `Parser` object.
     */
    public convenience init(data: Data) {
        self.init(parser: XMLParser(data: data))
    }

    convenience init?(data: Data?) {
        guard let data = data else {
            return nil
        }
        self.init(data: data)
    }

    /**
     Initializes a parser with the XML contents from the specified stream.

     - parameter stream: The input stream. The content is incrementally loaded
     from the specified stream and parsed. The `Parser` will open the stream,
     and synchronously read from it without scheduling it.

     - returns: An initialized `Parser` object.
     */
    public convenience init(stream: InputStream) {
        self.init(parser: XMLParser(stream: stream))
    }

    convenience init?(parser: XMLParser?) {
        guard let parser = parser else {
            return nil
        }

        self.init(parser: parser)
    }

    init(parser: XMLParser) {
        self.parser = parser
    }

    /**
     Performs the parsing operation.

     - returns: The result of the parsing operation.
     */
    public final func parse() -> ParserResult {
        let docParser = DocumentParser()
        parser.delegate = docParser

        guard parser.parse(), let document = docParser.document else {
            let error = MiniDOMError.from(parser.parserError)
            log.error("Error parsing document: \(error)")
            return .failure(error)
        }

        parser.delegate = nil
        return .success(document)
    }

    public final func streamElements(to stream: @escaping (Element) -> Bool, filter: @escaping (String) -> Bool) {
        let streamParser = StreamingParser(stream: stream, filter: filter)
        parser.delegate = streamParser
        parser.parse()
        parser.delegate = nil
    }
}

class DocumentParser: NSObject, XMLParserDelegate {

    var document: Document? {
        return stack.first as? Document
    }

    private let log = Log(level: .warn)
    private var stack = NodeStack()

    func parserDidStartDocument(_ parser: XMLParser) {
        log.debug("")
        do {
            try stack.append(Document())
        }
        catch {
            parser.abortParsing()
        }
    }

    func parserDidEndDocument(_ parser: XMLParser) {
        log.debug("")
        // no-op; leave top of stack for caller
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        log.debug("elementName=\(elementName) attributes=\(attributeDict)")
        do {
            try stack.append(Element(tagName: elementName, attributes: attributeDict))
        }
        catch {
            parser.abortParsing()
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        log.debug("elementName=\(elementName)")
        do {
            try stack.popAndAppend()
        }
        catch {
            parser.abortParsing()
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        do {
            try stack.append(Text(text: string))
        }
        catch {
            parser.abortParsing()
        }
    }

    func parser(_ parser: XMLParser, foundProcessingInstructionWithTarget target: String, data: String?) {
        log.debug("target=\(target) data=\(String(describing: data))")
        do {
            try stack.append(ProcessingInstruction(target: target, data: data))
        }
        catch {
            parser.abortParsing()
        }
    }

    func parser(_ parser: XMLParser, foundComment comment: String) {
        log.debug("comment=\(comment)")
        do {
            try stack.append(Comment(text: comment))
        }
        catch {
            parser.abortParsing()
        }
    }

    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        log.debug("CDATABlock=\(CDATABlock)")
        guard let text = String(data: CDATABlock, encoding: .utf8) else {
            log.error("invalid encoding")
            parser.abortParsing()
            return
        }

        do {
            try stack.append(CDATASection(text: text))
        }
        catch {
            parser.abortParsing()
        }
    }
}

class StreamingParser: NSObject, XMLParserDelegate {

    let stream: (Element) -> Bool
    let filter: (String) -> Bool

    private let log = Log(level: .warn)
    private var stacks: ArraySlice<NodeStack> = []

    init(stream: @escaping (Element) -> Bool, filter: @escaping (String) -> Bool) {
        self.stream = stream
        self.filter = filter
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        log.debug("elementName=\(elementName) attributes=\(attributeDict)")

        if filter(elementName) {
            stacks.append(NodeStack())
        }

        do {
            try stacks.last?.append(Element(tagName: elementName, attributes: attributeDict))
        }
        catch {
            parser.abortParsing()
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        log.debug("elementName=\(elementName)")

        autoreleasepool {
            do {
                try stacks.last?.popAndAppend()

                if filter(elementName),
                   let element = stacks.popLast()?.first as? Element {
                    if !stream(element) {
                        parser.abortParsing()
                    }
                    try stacks.last?.append(element)
                    try stacks.last?.popAndAppend()
                }
            }
            catch {
                parser.abortParsing()
            }
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        do {
            try stacks.last?.append(Text(text: string))
        }
        catch {
            parser.abortParsing()
        }
    }

    func parser(_ parser: XMLParser, foundProcessingInstructionWithTarget target: String, data: String?) {
        log.debug("target=\(target) data=\(String(describing: data))")
        do {
            try stacks.last?.append(ProcessingInstruction(target: target, data: data))
        }
        catch {
            parser.abortParsing()
        }
    }

    func parser(_ parser: XMLParser, foundComment comment: String) {
        log.debug("comment=\(comment)")
        do {
            try stacks.last?.append(Comment(text: comment))
        }
        catch {
            parser.abortParsing()
        }
    }

    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        log.debug("CDATABlock=\(CDATABlock)")
        guard let text = String(data: CDATABlock, encoding: .utf8) else {
            log.error("invalid encoding")
            parser.abortParsing()
            return
        }

        do {
            try stacks.last?.append(CDATASection(text: text))
        }
        catch {
            parser.abortParsing()
        }
    }
}

private class NodeStack {

    enum Error: Swift.Error {
        case invalidState
    }

    var first: Node? {
        return stack.first
    }

    private var stack: ArraySlice<Node> = []

    func append(_ node: Node) throws {
        if node is ParentNode {
            stack.append(node)
        }
        else if var parent = stack.popLast() as? ParentNode {
            parent.append(child: node)
            stack.append(parent)
        }
        else {
            throw Error.invalidState
        }
    }

    func popAndAppend() throws {
        guard let child = stack.popLast() else {
            throw Error.invalidState
        }

        if var parent = stack.popLast() as? ParentNode {
            parent.append(child: child)
            stack.append(parent)
        }
        else if child is ParentNode {
            stack.append(child)
        }
        else {
            throw Error.invalidState
        }
    }
}
