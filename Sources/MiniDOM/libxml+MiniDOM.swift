//
//  libxml+MiniDOM.swift
//  MiniDOM
//
//  Created by Rob Visentin on 10/26/21.
//  Copyright © 2021 Anodized Software, Inc. All rights reserved.
//

import libxml2

public extension Document {

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

public extension Element {

    init(xmlNode: xmlNodePtr) {
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

public extension xmlDocPtr {

    func toDocument() -> Document {
        return Document(xmlDoc: self)
    }

}

// MARK: - Private

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
