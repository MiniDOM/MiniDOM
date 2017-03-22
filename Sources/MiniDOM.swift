//
//  MiniDOM.swift
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

public enum NodeType {
    case document
    case element
    case text
    case processingInstruction
    case comment
    case cdataSection
}

// MARK: - Node Protocol

public protocol Node: Visitable {
    static var nodeType: NodeType { get }

    var nodeName: String { get }

    var nodeValue: String? { get }

    var children: [Node] { get set }
}

public extension Node {
    var nodeType: NodeType {
        return Self.nodeType
    }

    public mutating func append(child: Node) {
        children.append(child)
    }

    public func children<T: Node>(ofType type: T.Type) -> [T] {
        return only(nodes: children, ofType: type)
    }

    public var hasChildren: Bool {
        return children.count > 0
    }

    public var firstChild: Node? {
        return children.first
    }

    public var lastChild: Node? {
        return children.last
    }
}

// MARK: - TextNode Protocol

public protocol TextNode: Node {
    var text: String { get set }
}

public extension TextNode {
    var nodeValue: String? {
        return text
    }
}

// MARK: - Document

public class Document: Node {

    // MARK: Node

    public static let nodeType: NodeType = .document

    public let nodeName: String = "#document"

    public let nodeValue: String? = nil

    public var children: [Node] = []

    // MARK: Document

    public var documentElement: Element? {
        return first(in: children, ofType: Element.self)
    }
}

// MARK: - Element

public class Element: Node {

    // MARK: Node

    public static let nodeType: NodeType = .element

    public var nodeName: String {
        return tagName
    }

    public let nodeValue: String? = nil

    public var children: [Node] = []

    // MARK: Element

    public var tagName: String

    public var namespaceURI: String?

    public var qualifiedName: String?

    public var attributes: [String : String]

    // MARK: Initializer

    public init(tagName: String, namespaceURI: String?, qualifiedName: String?, attributes: [String : String]) {
        self.tagName = tagName
        self.namespaceURI = namespaceURI
        self.qualifiedName = qualifiedName
        self.attributes = attributes
    }
}

// MARK: - Text

public class Text: TextNode {

    // MARK: Node

    public static let nodeType: NodeType = .text

    public let nodeName: String = "#text"

    public var children: [Node] = []

    // MARK: TextNode

    public var text: String

    // MARK: Initializer

    public init(text: String) {
        self.text = text
    }
}

// MARK: - ProcessingInstruction

public class ProcessingInstruction: Node {

    // MARK: Node

    public static let nodeType: NodeType = .processingInstruction

    public var nodeName: String {
        return target
    }

    public var nodeValue: String? {
        return data
    }

    public var children: [Node] = []

    // MARK: ProcessingInstruction

    public var target: String

    public var data: String?

    // MARK: Initializer

    public init(target: String, data: String?) {
        self.target = target
        self.data = data
    }
}

// MARK: - Comment

public class Comment: TextNode {

    // MARK: Node

    public static let nodeType: NodeType = .comment

    public let nodeName: String = "#comment"

    public var children: [Node] = []

    // MARK: TextNode

    public var text: String

    // MARK: Initializer

    public init(text: String) {
        self.text = text
    }
}

// MARK: - CDATASection

public class CDATASection: TextNode {

    // MARK: Node

    public static let nodeType: NodeType = .cdataSection

    public let nodeName: String = "#cdata-section"

    public var children: [Node] = []

    // MARK: TextNode
    
    public var text: String

    // MARK: Initializer
    
    public init(text: String) {
        self.text = text
    }
}
