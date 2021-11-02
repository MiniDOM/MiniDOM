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

public protocol SAXConsumer: AnyObject {

    var continueParsing: Bool { get }

    func didStartDocument()
    func didEndDocument()

    func didStart(elementName: String, attributes: [String: String])
    func didEnd(elementName: String)

    func foundCharacters(in string: String)
    func foundProcessingInstruction(target: String, data: String?)
    func foundComment(_ comment: String)
    func foundCDATA(_ CDATAString: String)

}

public class SAXParser: SAXConsumer {

    private let stream: InputStream
    private let log = Log(level: .all)

    public private(set) var continueParsing = true

    private var consumers = NSHashTable<AnyObject>()
    private var activeConsumers = [SAXConsumer]()

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

    public convenience init?(data: Data?) {
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
     Adds the given consumer to the list of objects that receive callbacks during parsing.
     */
    public func add(consumer: SAXConsumer) {
        consumers.add(consumer)
    }

    /**
     Removes the given consumer from the list of objects that receive callbacks during parsing.
     */
    public func remove(consumer: SAXConsumer) {
        consumers.remove(consumer)
    }

    /**
     Parses the stream synchronously and reports elements found. After `streamElements` has been called,
     subsequent calls to `streamElements` on the receiver have no effect.

     - parameter callback: The callback to invoke whenever an element matching `filter` is parsed.
     - parameter filter: Given an element name and attributes, return `true` to parse and invoke `callback` for this element.
     Adds the given consumer to the list of objects that receive callbacks during parsing.
     */
    public func streamElements(to callback: @escaping (Element) throws -> Bool, filter: @escaping (String) -> Bool) {
        guard stream.streamStatus != .closed else {
            return
        }
        add(consumer: ElementStream(callback: callback, filter: filter))
        parse()
    }

    /**
     Parses the stream synchronously and invokes callbacks on all `consumers`. After `parse` has been called,
     subsequent calls to `parse` on the receiver have no effect.
     */
    public func parse() {
        guard stream.streamStatus != .closed else {
            return
        }

        var handler = xmlSAXHandler()
        handler.initialized = XML_SAX2_MAGIC
        handler.startDocument = SAXParser_startDocument
        handler.endDocument = SAXParser_endDocument
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

        let bufferSize = 1024
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

        activeConsumers = consumers.allObjects as? [SAXConsumer] ?? []
        continueParsing = true

        while stream.hasBytesAvailable && continueParsing {
            autoreleasepool {
                len = stream.read(buffer, maxLength: bufferSize)

                if let error = stream.streamError {
                    log.error("SAXParser stream error: \(error)")
                    continueParsing = false
                }
                else if len == 0 {
                    continueParsing = false
                }
                else {
                    let result = buffer.withMemoryRebound(to: CChar.self, capacity: 4) {
                        xmlParseChunk(pushParser, $0, Int32(len), stream.hasBytesAvailable ? 0 : 1)
                    }

                    if result != 0 {
                        log.error("SAXParser parse error: \(result)")
                        continueParsing = false
                    }
                }

                if activeConsumers.isEmpty {
                    continueParsing = false
                }
            }
        }
    }
}

// MARK: - SAXConsumer

public extension SAXParser {

    func didStartDocument() {
        activeConsumers.forEach { $0.didStartDocument() }
        activeConsumers = activeConsumers.filter { $0.continueParsing }
    }

    func didEndDocument() {
        activeConsumers.forEach { $0.didEndDocument() }
        activeConsumers = activeConsumers.filter { $0.continueParsing }
    }

    func didStart(elementName: String, attributes: [String: String]) {
        activeConsumers.forEach { $0.didStart(elementName: elementName, attributes: attributes) }
        activeConsumers = activeConsumers.filter { $0.continueParsing }
    }

    func didEnd(elementName: String) {
        activeConsumers.forEach { $0.didEnd(elementName: elementName) }
        activeConsumers = activeConsumers.filter { $0.continueParsing }
    }

    func foundCharacters(in string: String) {
        activeConsumers.forEach { $0.foundCharacters(in: string) }
        activeConsumers = activeConsumers.filter { $0.continueParsing }
    }

    func foundProcessingInstruction(target: String, data: String?) {
        activeConsumers.forEach { $0.foundProcessingInstruction(target: target, data: data) }
        activeConsumers = activeConsumers.filter { $0.continueParsing }
    }

    func foundComment(_ comment: String) {
        activeConsumers.forEach { $0.foundComment(comment) }
        activeConsumers = activeConsumers.filter { $0.continueParsing }
    }

    func foundCDATA(_ CDATAString: String) {
        activeConsumers.forEach { $0.foundCDATA(CDATAString) }
        activeConsumers = activeConsumers.filter { $0.continueParsing }
    }
}

// MARK: - Private

private func SAXParser_startDocument(ctx: UnsafeMutableRawPointer?) {
    guard let ctx = ctx else {
        return
    }

    let parser = Unmanaged<SAXParser>.fromOpaque(ctx).takeUnretainedValue()
    parser.didStartDocument()
}

private func SAXParser_endDocument(ctx: UnsafeMutableRawPointer?) {
    guard let ctx = ctx else {
        return
    }

    let parser = Unmanaged<SAXParser>.fromOpaque(ctx).takeUnretainedValue()
    parser.didEndDocument()
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

    let parser = Unmanaged<SAXParser>.fromOpaque(ctx).takeUnretainedValue()
    parser.didStart(elementName: name, attributes: attributes)
}

private func SAXParser_endElement(ctx: UnsafeMutableRawPointer?, name: UnsafePointer<xmlChar>?) {
    guard let ctx = ctx,
          let name = name?.value else {
        return
    }

    let parser = Unmanaged<SAXParser>.fromOpaque(ctx).takeUnretainedValue()
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

    let parser = Unmanaged<SAXParser>.fromOpaque(ctx).takeUnretainedValue()
    parser.foundCharacters(in: string)
}

private func SAXParser_processingInstruction(ctx: UnsafeMutableRawPointer?, target: UnsafePointer<xmlChar>?, data: UnsafePointer<xmlChar>?) {
    guard let ctx = ctx,
          let target = target?.value,
          let data = data?.value else {
        return
    }

    let parser = Unmanaged<SAXParser>.fromOpaque(ctx).takeUnretainedValue()
    parser.foundProcessingInstruction(target: target, data: data)
}

private func SAXParser_comment(ctx: UnsafeMutableRawPointer?, comment: UnsafePointer<xmlChar>?) {
    guard let ctx = ctx,
          let comment = comment?.value else {
        return
    }

    let parser = Unmanaged<SAXParser>.fromOpaque(ctx).takeUnretainedValue()
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

    let parser = Unmanaged<SAXParser>.fromOpaque(ctx).takeUnretainedValue()
    parser.foundCDATA(string)
}
