//
//  DOMParser.swift
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

/**
 Instances of this class parse XML documents into a tree of DOM objects.
 */
public class DOMParser {

    private let data: Data

    /**
     Initializes a parser with the XML content referenced by the given URL.

     - parameter url: A `URL` object specifying a URL. The URL must be fully
     qualified and refer to a scheme that is supported by the `URL` type.

     - returns: An initialized `DOMParser` object or `nil` if an error occurs.
     */
    public convenience init?(contentsOf url: URL) {
        guard let data = try? Data(contentsOf: url) else {
            return nil
        }
        self.init(data: data)
    }

    /**
     Initializes a parser with the XML contents encapsulated in a given string
     object.

     - parameter string: A `String` object containing XML markup.

     - parameter encoding: The encoding of the `String` object.

     - returns: An initialized `DOMParser` object or `nil` if an error occurs.
     */
    public convenience init?(string: String, encoding: String.Encoding = .utf8) {
        self.init(data: string.data(using: encoding))
    }

    /**
     Initializes a parser with the XML contents encapsulated in a given data
     object.

     - parameter data: A `Data` object containing XML markup.

     - returns: An initialized `DOMParser` object.
     */
    public init(data: Data) {
        self.data = data
    }

    convenience init?(data: Data?) {
        guard let data = data else {
            return nil
        }
        self.init(data: data)
    }

    /**
     Performs the parsing operation.

     - returns: The result of the parsing operation.
     */
    public final func parse() -> ParserResult {
        var result: ParserResult!

        data.withUnsafeBytes {
            guard let xmlDoc = xmlReadMemory($0.bindMemory(to: CChar.self).baseAddress, Int32(data.count), nil, nil, 0) else {
                result = .failure(.unspecifiedError)
                return
            }

            result = .success(Document(xmlDoc: xmlDoc))
            xmlFreeDoc(xmlDoc)
        }

        return result
    }
}

// MARK: - Private

private extension Document {

    init(xmlDoc: xmlDocPtr) {
        var children = [Node]()
        var child = xmlDoc.pointee.children

        while child != nil {
            child?.makeNode().map {
                children.append($0)
            }
            child = child?.pointee.next
        }

        self.children = children
    }
}

private extension Element {

    init?(xmlNode: xmlNodePtr) {
        let name = xmlNode.pointee.name
        let prefix = xmlNode.pointee.ns?.pointee.prefix

        self.tagName = [prefix, name].joined(separator: ":")

        if xmlNode.pointee.nsDef != nil {
            var attributes = self.attributes ?? [String: String]()
            var nsDef = xmlNode.pointee.nsDef

            while nsDef != nil {
                if let href = nsDef?.pointee.href {
                    let key = ["xmlns", nsDef?.pointee.prefix].joined(separator: ":")
                    attributes[key] = href.value
              }
                nsDef = nsDef?.pointee.next
            }

            self.attributes = attributes
        }

        if xmlNode.pointee.properties != nil {
            var attributes = self.attributes ?? [String: String]()
            var attribute = xmlNode.pointee.properties

            while attribute != nil {
                if let attributeName = attribute?.pointee.name,
                   let attributeValue = xmlGetProp(xmlNode, attributeName) {
                    let key = [attribute?.pointee.ns?.pointee.prefix, attributeName].joined(separator: ":")
                    attributes[key] = attributeValue.value
                    xmlFree(attributeValue)
              }
              attribute = attribute?.pointee.next
            }

            self.attributes = attributes
        }

        var children = [Node]()
        var child = xmlNode.pointee.children

        while child != nil {
            child?.makeNode().map {
                children.append($0)
            }
            child = child?.pointee.next
        }

        self.children = children
    }
}

private extension xmlNodePtr {

    func makeNode() -> Node? {
        switch pointee.type {
        case XML_ELEMENT_NODE:
            return Element(xmlNode: self)
        case XML_TEXT_NODE:
            return pointee.content.map {
                Text(text: $0.value)
            }
        case XML_PI_NODE:
            guard let target = pointee.name, let data = pointee.content else {
                return nil
            }
            return ProcessingInstruction(target: target.value, data: data.value)
        case XML_COMMENT_NODE:
            return pointee.content.map {
                Comment(text: $0.value)
            }
        case XML_CDATA_SECTION_NODE:
            return pointee.content.map {
                CDATASection(text: $0.value)
            }
        default:
            return nil
        }
    }
}
