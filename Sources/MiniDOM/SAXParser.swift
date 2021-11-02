//
//  SAXParser.swift
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
import libxml2

public class SAXParser {

    private let stream: InputStream
    private let log = Log(level: .all)

    /**
     Initializes a parser with the XML content referenced by the given URL.

     - parameter url: A `URL` object specifying a URL. The URL must be fully
     qualified and refer to a scheme that is supported by the `URL` type.

     - returns: An initialized `SAXParser` object or `nil` if an error occurs.
     */
    public convenience init?(contentsOf url: URL) {
        guard let stream = InputStream(url: url) else {
            return nil
        }
        self.init(stream: stream)
    }

    /**
     Initializes a parser with the XML contents encapsulated in a given data
     object.

     - parameter data: A `Data` object containing XML markup.

     - returns: An initialized `SAXParser` object.
     */
    public convenience init(data: Data) {
        self.init(stream: InputStream(data: data))
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
     from the specified stream and parsed. The `SAXParser` will open the stream,
     and synchronously read from it without scheduling it.

     - returns: An initialized `SAXParser` object.
     */
    public init(stream: InputStream) {
        self.stream = stream
    }

    /**
     Parses the stream synchronously and reports elements found. After `streamElements` has been called,
     subsequent calls to `streamElements` on the receiver have no effect.

     - parameter callback: The callback to invoke whenever an element matching `filter` is parsed.
     - parameter filter: Given an element name and attributes, return `true` to parse and invoke `callback` for this element.
     */
    public func streamElements(to callback: @escaping (Element) throws -> Bool, filter: @escaping (String, [String: String]) -> Bool) {
        guard stream.streamStatus != .closed else {
            return
        }
        SAXParserImpl(callback: callback, filter: filter).parse(stream: stream)
    }
}

// MARK: - Private

private class SAXParserImpl {

    let callback: (Element) throws -> Bool
    let filter: (String, [String: String]) -> Bool

    private let log = Log(level: .warn)
    private var stacks: ArraySlice<NodeStack> = []
    private var stopParsing = false

    init(callback: @escaping (Element) throws -> Bool, filter: @escaping (String, [String: String]) -> Bool) {
        self.callback = callback
        self.filter = filter
    }

    func parse(stream: InputStream) {
        defer {
            stopParsing = false
        }

        var handler = xmlSAXHandler()
        handler.initialized = XML_SAX2_MAGIC
        handler.startElement = SAXParser_startElement
        handler.endElement = SAXParser_endElement
        handler.characters = SAXParser_characters
        handler.processingInstruction = SAXParser_processingInstruction
        handler.comment = SAXParser_comment
        handler.cdataBlock = SAXParser_cdata

        let parser = Unmanaged.passRetained(self)
        defer {
            parser.release()
        }

        let bufferSize = 2048
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer {
            buffer.deallocate()
        }

        stream.open()
        defer {
            stream.close()
        }

        var len = stream.read(buffer, maxLength: 4)

        if let error = stream.streamError {
            log.error("SAXParser stream error: \(error)")
            return
        }

        guard let pushParser = buffer.withMemoryRebound(to: CChar.self, capacity: 4, {
            xmlCreatePushParserCtxt(&handler, parser.toOpaque(), $0, Int32(len), nil)
        }) else {
            return
        }

        defer {
            xmlFreeParserCtxt(pushParser)
        }

        while stream.hasBytesAvailable && !stopParsing {
            autoreleasepool {
                len = stream.read(buffer, maxLength: bufferSize)

                if let error = stream.streamError {
                    log.error("SAXParser stream error: \(error)")
                    stopParsing = true
                }
                else if len == 0 {
                    stopParsing = true
                }
                else {
                    let result = buffer.withMemoryRebound(to: CChar.self, capacity: 4) {
                        xmlParseChunk(pushParser, $0, Int32(len), stream.hasBytesAvailable ? 0 : 1)
                    }

                    if result != 0 {
                        log.error("SAXParser parse error: \(result)")
                        stopParsing = true
                    }
                }
            }
        }
    }

    func didStart(elementName: String, attributes: [String: String]) {
        guard !stopParsing else {
            return
        }

        log.debug("start elementName=\(elementName) attributes=\(attributes)")

        if filter(elementName, attributes) {
            stacks.append(NodeStack())
        }

        do {
            try stacks.last?.append(node: Element(tagName: elementName, attributes: attributes))
        }
        catch {
            stopParsing = true
        }
    }

    func didEnd(elementName: String) {
        guard !stopParsing else {
            return
        }

        log.debug("end elementName=\(elementName)")

        autoreleasepool {
            do {
                try stacks.last?.popAndAppend()

                if let element = stacks.last?.first as? Element,
                   element.tagName == elementName,
                   filter(elementName, element.attributes ?? [:]) {
                    if try callback(element) {
                        stacks.removeLast()
                        try stacks.last?.append(node: element)
                        try stacks.last?.popAndAppend()
                    }
                    else {
                        stopParsing = true
                    }
                }
            }
            catch {
                stopParsing = true
            }
        }
    }

    func foundCharacters(in string: String) {
        guard !stopParsing else {
            return
        }

        do {
            try stacks.last?.append(string: string, nodeType: Text.self)
        }
        catch {
            stopParsing = true
        }
    }

    func foundProcessingInstruction(target: String, data: String?) {
        guard !stopParsing else {
            return
        }

        log.debug("processing instruction target=\(target) data=\(String(describing: data))")

        do {
            try stacks.last?.append(node: ProcessingInstruction(target: target, data: data))
        }
        catch {
            stopParsing = true
        }
    }

    func foundComment(_ comment: String) {
        guard !stopParsing else {
            return
        }

        log.debug("comment=\(comment)")

        do {
            try stacks.last?.append(node: Comment(text: comment))
        }
        catch {
            stopParsing = true
        }
    }

    func foundCDATA(_ CDATAString: String) {
        guard !stopParsing else {
            return
        }

        log.debug("CDATA=\(CDATAString)")

        do {
            try stacks.last?.append(string: CDATAString, nodeType: CDATASection.self)
        }
        catch {
            stopParsing = true
        }
    }
}

private func SAXParser_startElement(ctx: UnsafeMutableRawPointer?, name: UnsafePointer<xmlChar>?, attributesList: UnsafeMutablePointer<UnsafePointer<xmlChar>?>?) {
    guard let ctx = ctx,
          let name = name?.value else {
        return
    }

    var attributes = [String: String]()

    var attributeIterator = attributesList
    while attributeIterator != nil {
        guard let attributeName = attributeIterator?[0],
              let attributeValue = attributeIterator?[1] else {
            break
        }

        attributes[attributeName.value] = attributeValue.value
        attributeIterator = attributeIterator?.advanced(by: 2)
    }

    let parser = Unmanaged<SAXParserImpl>.fromOpaque(ctx).takeUnretainedValue()
    parser.didStart(elementName: name, attributes: attributes)
}

private func SAXParser_endElement(ctx: UnsafeMutableRawPointer?, name: UnsafePointer<xmlChar>?) {
    guard let ctx = ctx,
          let name = name?.value else {
        return
    }

    let parser = Unmanaged<SAXParserImpl>.fromOpaque(ctx).takeUnretainedValue()
    parser.didEnd(elementName: name)
}

private func SAXParser_characters(ctx: UnsafeMutableRawPointer?, characters: UnsafePointer<xmlChar>?, len: Int32) {
    guard let ctx = ctx,
          let data = characters.map({
              Data(bytesNoCopy: UnsafeMutablePointer(mutating: $0), count: Int(len), deallocator: .none)
          }),
          let string = String(data: data, encoding: .utf8) else {
        return
    }

    let parser = Unmanaged<SAXParserImpl>.fromOpaque(ctx).takeUnretainedValue()
    parser.foundCharacters(in: string)
}

private func SAXParser_processingInstruction(ctx: UnsafeMutableRawPointer?, target: UnsafePointer<xmlChar>?, data: UnsafePointer<xmlChar>?) {
    guard let ctx = ctx,
          let target = target?.value,
          let data = data?.value else {
        return
    }

    let parser = Unmanaged<SAXParserImpl>.fromOpaque(ctx).takeUnretainedValue()
    parser.foundProcessingInstruction(target: target, data: data)
}

private func SAXParser_comment(ctx: UnsafeMutableRawPointer?, comment: UnsafePointer<xmlChar>?) {
    guard let ctx = ctx,
          let comment = comment?.value else {
        return
    }

    let parser = Unmanaged<SAXParserImpl>.fromOpaque(ctx).takeUnretainedValue()
    parser.foundComment(comment)
}

private func SAXParser_cdata(ctx: UnsafeMutableRawPointer?, characters: UnsafePointer<xmlChar>?, len: Int32) {
    guard let ctx = ctx,
          let data = characters.map({
              Data(bytesNoCopy: UnsafeMutablePointer(mutating: $0), count: Int(len), deallocator: .none)
          }),
          let string = String(data: data, encoding: .utf8) else {
        return
    }

    let parser = Unmanaged<SAXParserImpl>.fromOpaque(ctx).takeUnretainedValue()
    parser.foundCDATA(string)
}
