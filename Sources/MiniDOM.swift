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

/*
 This file contains the protocols and classes used to define the Document
 Object Model.

 This is intended to provided a subset of the behavior described in the
 [DOM Level 1 specification][1]. Much of this file's documentation is adapted
 from that document.

 [1]: https://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html
 */

import Foundation

/// An `enum` indicating the type of a `Node` object.
public enum NodeType {

    /// A `Document` object
    case document

    /// An `Element` object
    case element

    /// A `Text` object
    case text

    /// A `ProcessingInstruction` object
    case processingInstruction

    /// A `Comment` object
    case comment

    /// A `CDATASection` object
    case cdataSection
}

// MARK: - Node Protocol

/**
 The `Node` protocol is the primary data type for the entire Document Object
 Model. It represents a single node in the document tree. While all objects
 implementing the `Node` protocol expose functionality related to children, not
 all objects implementing the `Node` protocol may have children. To address this
 distinction, there are two additional protocols implemented by node types:

 - `ParentNode` provides a getter and setter on the `children` property
 - `LeafNode` provides a getter on the `children` property that always returns
 an empty array.

 This is a departure from the standard DOM which would throw an error when
 attempting to modify the `children` array of a leaf node.

 The attributes `nodeName`, `nodeValue`, and `attributes` are included as a
 mechanism to get at node information without casting down to the specific
 derived type. In cases where there is no obvious mapping of these attributes
 for a specific `nodeType` (e.g., `nodeValue` for an Element or `attributes` for
 a Comment), this returns `nil`.

 The values of `nodeName`, `nodeValue`, and `attributes` vary according to the
 node type.
 */
public protocol Node: Visitable {
    /**
     Indicates which type of node this is.

     - SeeAlso: [`Document.nodeType`](Document.html#//apple_ref/swift/Property/nodeType)
     - SeeAlso: [`Element.nodeType`](Element.html#//apple_ref/swift/Property/nodeType)
     - SeeAlso: [`Text.nodeType`](Text.html#//apple_ref/swift/Property/nodeType)
     - SeeAlso: [`ProcessingInstruction.nodeType`](ProcessingInstruction.html#//apple_ref/swift/Property/nodeType)
     - SeeAlso: [`Comment.nodeType`](Comment.html#//apple_ref/swift/Property/nodeType)
     - SeeAlso: [`CDATASection.nodeType`](CDATASection.html#//apple_ref/swift/Property/nodeType)
     */
    static var nodeType: NodeType { get }

    /**
     The name of this node, depending on its type.

     - SeeAlso: [`Document.nodeName`](Document.html#//apple_ref/swift/Property/nodeName)
     - SeeAlso: [`Element.nodeName`](Element.html#//apple_ref/swift/Property/nodeName)
     - SeeAlso: [`Text.nodeName`](Text.html#//apple_ref/swift/Property/nodeName)
     - SeeAlso: [`ProcessingInstruction.nodeName`](ProcessingInstruction.html#//apple_ref/swift/Property/nodeName)
     - SeeAlso: [`Comment.nodeName`](Comment.html#//apple_ref/swift/Property/nodeName)
     - SeeAlso: [`CDATASection.nodeName`](CDATASection.html#//apple_ref/swift/Property/nodeName)
     */
    var nodeName: String { get }

    /**
     The value of this node, depending on its type.

     - SeeAlso: [`Document.nodeValue`](Document.html#//apple_ref/swift/Property/nodeValue)
     - SeeAlso: [`Element.nodeValue`](Element.html#//apple_ref/swift/Property/nodeValue)
     - SeeAlso: [`Text.nodeValue`](Text.html#//apple_ref/swift/Property/nodeValue)
     - SeeAlso: [`ProcessingInstruction.nodeValue`](ProcessingInstruction.html#//apple_ref/swift/Property/nodeValue)
     - SeeAlso: [`Comment.nodeValue`](Comment.html#//apple_ref/swift/Property/nodeValue)
     - SeeAlso: [`CDATASection.nodeValue`](CDATASection.html#//apple_ref/swift/Property/nodeValue)
     */
    var nodeValue: String? { get }

    /**
     The attributes of this node, depending on its type.

     - SeeAlso: [`Document.attributes`](Document.html#//apple_ref/swift/Property/attributes)
     - SeeAlso: [`Element.attributes`](Element.html#//apple_ref/swift/Property/attributes)
     - SeeAlso: [`Text.attributes`](Text.html#//apple_ref/swift/Property/attributes)
     - SeeAlso: [`ProcessingInstruction.attributes`](ProcessingInstruction.html#//apple_ref/swift/Property/attributes)
     - SeeAlso: [`Comment.attributes`](Comment.html#//apple_ref/swift/Property/attributes)
     - SeeAlso: [`CDATASection.attributes`](CDATASection.html#//apple_ref/swift/Property/attributes)
     */
    var attributes: [String : String]? { get }

    /**
     The children of this node.

     - SeeAlso: [`Document.children`](Document.html#//apple_ref/swift/Property/children)
     - SeeAlso: [`Element.children`](Element.html#//apple_ref/swift/Property/children)
     - SeeAlso: [`Text.children`](Text.html#//apple_ref/swift/Property/children)
     - SeeAlso: [`ProcessingInstruction.children`](ProcessingInstruction.html#//apple_ref/swift/Property/children)
     - SeeAlso: [`Comment.children`](Comment.html#//apple_ref/swift/Property/children)
     - SeeAlso: [`CDATASection.children`](CDATASection.html#//apple_ref/swift/Property/children)
     */
    var children: [Node] { get }
}

public extension Node {
    /// Convenience accessor for the static `nodeType` property.
    final var nodeType: NodeType {
        return Self.nodeType
    }

    /**
     Filters the `children` array, keeping only nodes of the specified type.
     Casts the nodes in the resulting array to the specified type.

     - parameter type: Include children of this type in the resulting array
     
     - returns: The nodes in the `children` array of the specified type
     */
    public final func children<T: Node>(ofType type: T.Type) -> [T] {
        return only(nodes: children, ofType: type)
    }

    /// A Boolean value indicating whether the `children` array is not empty.
    public final var hasChildren: Bool {
        return !children.isEmpty
    }

    /// The first node in the `children` array.
    public final var firstChild: Node? {
        return children.first
    }

    /// The last node in the `children` array.
    public final var lastChild: Node? {
        return children.last
    }
}

// MARK: - Leaf Protocol

/**
 Represents a node that cannot have children.
 */
public protocol LeafNode: Node {
    /**
     A leaf node does not have children. The value of this property is always
     an empty array.
     */
    var children: [Node] { get }
}

public extension LeafNode {
    /**
     A leaf node does not have children. The value of this property is always
     an empty array.
     */
    final var children: [Node] {
        return []
    }
}

// MARK: - Parent Protocol

/**
 Represents a node that can have children.
 */
public protocol ParentNode: Node {
    /// The children of this node.
    var children: [Node] { get set }
}

public extension ParentNode {
    /**
     Appends the specified node to the end of the `children` array.

     - parameter child: The node to append
     */
    public mutating func append(child: Node) {
        children.append(child)
    }
}

// MARK: - TextNode Protocol

/**
 Represents a node with a text value.
 */
public protocol TextNode: LeafNode {
    /// The text value associated with this node.
    var text: String { get set }
}

public extension TextNode {
    /// The `nodeValue` of a `TextNode` node is its `text` property.
    var nodeValue: String? {
        return text
    }
}

// MARK: - Document

/**
 The `Document` class represents the entire document. Conceptually, it is the
 root of the document tree, and provides the primary access to the document's
 data.
 */
public final class Document: ParentNode {

    // MARK: Node

    /// The `nodeType` of a `Document` is `.document`.
    public static let nodeType: NodeType = .document

    /// The `nodeName` of a `Document` is `#document`.
    public let nodeName: String = "#document"

    /// The `nodeValue` of a `Document` is `nil`.
    public let nodeValue: String? = nil

    /**
     The children of the document will contain the document element and any
     processing instructions or comments that are siblings of the documnent
     element.
     */
    public var children: [Node] = []

    /// The `attributes` dictionary of a `Document` is `nil`.
    public let attributes: [String : String]? = nil

    // MARK: Document

    /**
     This is a convenience attribute that allows direct access to the child node
     that is the root element of the document.
     */
    public var documentElement: Element? {
        return first(in: children, ofType: Element.self)
    }

    /**
     Creates a new `Document` node.
     */
    public init() { }
}

// MARK: - Element

/**
 By far the vast majority of objects (apart from text) that authors encounter
 when traversing a document are Element nodes. Assume the following XML
 document:

 ```xml
 <elementExample id="demo">
   <subelement1/>
   <subelement2><subsubelement/></subelement2>
 </elementExample>
 ```

 When represented using the DOM, the top node is an `Element` node for
 `elementExample`, which contains two child `Element` nodes, one for
 `subelement1` and one for `subelement2`. `subelement1` contains no child
 nodes.

 Elements may have attributes associated with them; since the `Element` class
 implements the `Node` protocol, the `attributes` property of the `Node`
 protocol may be used to retrieve a dictionary of the attributes for an element.
 */
public final class Element: ParentNode {

    // MARK: Node

    /// The `nodeType` of an `Element` is `.element`.
    public static let nodeType: NodeType = .element

    /// The `nodeName` of an `Element` is its `tagName`.
    public var nodeName: String {
        return tagName
    }

    /// The `nodeValue` of an `Element` is `nil`.
    public let nodeValue: String? = nil

    /// The children of the element.
    public var children: [Node] = []

    // MARK: Element

    /**
     The name of the element. For example, in:

     ```xml
     <elementExample id="demo">
        ...
     </elementExample>
     ```

     `tagName` has the value `"elementExample"`.
     */
    public var tagName: String

    /**
     If namespace processing is turned on, contains the URI for the current
     namespace.
     */
    public var namespaceURI: String?

    /**
     If namespace processing is turned on, contains the qualified name for the
     current namespace.
     */
    public var qualifiedName: String?

    /**
     A dictionary that contains any attributes associated with the element.
     Keys are the names of attributes, and values are attribute values.
     */
    public var attributes: [String : String]?

    // MARK: Initializer

    /**
     Creates a new `Element` node.

     - parameter tagName: A string that is the name of an element (in its start
     tag).

     - parameter namespaceURI: If namespace processing is turned on, contains
     the URI for the current namespace.

     - parameter qualifiedName: If namespace processing is turned on, contains
     the qualified name for the current namespace.

     - parameter attributes: A dictionary that contains any attributes
     associated with the element. Keys are the names of attributes, and values
     are attribute values.
     */
    public init(tagName: String, namespaceURI: String?, qualifiedName: String?, attributes: [String : String]) {
        self.tagName = tagName
        self.namespaceURI = namespaceURI
        self.qualifiedName = qualifiedName
        self.attributes = attributes
    }
}

// MARK: - Text

/**
 The `Text` class represents the textual content (termed character data in XML)
 of an `Element`. If there is no markup inside an element's content, the text is
 contained in a single object implementing the `Text` protocol that is the only
 child of the element. If there is markup, it is parsed into a sequence of 
 elements and `Text` nodes that form the array of children of the element.
 */
public class Text: TextNode {

    // MARK: Node

    /// The `nodeType` of a `Text` node is `.text`.
    public static let nodeType: NodeType = .text

    /// The `nodeName` of a `Text` node is `#text`.
    public let nodeName: String = "#text"

    /// The `attributes` dictionary of a `Text` node is `nil`.
    public let attributes: [String : String]? = nil

    // MARK: TextNode

    /// The string contents of this text node.
    public var text: String

    // MARK: Initializer

    /**
     Creates a new `Text` node.

     - parameter text: The string contents of this text node.
     */
    public init(text: String) {
        self.text = text
    }
}

// MARK: - ProcessingInstruction

/**
 The `ProcessingInstruction` class represents a "processing instruction", used
 in XML as a way to keep processor-secific information in the text of the
 document.
 */
public class ProcessingInstruction: LeafNode {

    // MARK: Node

    /// The `nodeType` of a `ProcessingInstruction` is `.processingInstruction`.
    public static let nodeType: NodeType = .processingInstruction

    /// The `nodeName` of a `ProcessingInstruction` is its `target`.
    public var nodeName: String {
        return target
    }

    /// The `nodeValue` of a `ProcessingInstruction` is its `data`.
    public var nodeValue: String? {
        return data
    }

    /// The `attributes` dictionary of a `ProcessingInstruction` is `nil`.
    public let attributes: [String : String]? = nil

    // MARK: ProcessingInstruction

    /**
     The target of this processing instruction. XML defines this as being the
     first token following the `<?` that begins the processing instruction.
     */
    public var target: String

    /**
     The content of this processing instruction. This is from the first
     non-whitespace character after the target to the character immediately
     preceding the `?>`.
     */
    public var data: String?

    // MARK: Initializer

    /**
     Creates a new `ProcessingInstruction' node.

     - parameter target: The target of this processing instruction. XML defines
     this as being the first token following the `<?` that begins the processing
     instruction.

     - parameter data: The content of this processing instruction. This is from
     the first non-whitespace character after the target to the character
     immediately preceding the `?>`.
     */
    public init(target: String, data: String?) {
        self.target = target
        self.data = data
    }
}

// MARK: - Comment

/**
 This represents the content of a comment, i.e., all the characters between the
 starting `<!--` and ending `-->`.
 */
public class Comment: TextNode {

    // MARK: Node

    /// The `nodeType` of a `Comment` is `.comment`.
    public static let nodeType: NodeType = .comment

    /// The `nodeName` of a `Comment` is `#comment`.
    public let nodeName: String = "#comment"

    /// The `attributes` dictionary of a `Comment` is `nil`.
    public let attributes: [String : String]? = nil

    // MARK: TextNode

    /// The string contents of this comment.
    public var text: String

    // MARK: Initializer

    /**
     Creates a new `Comment` node.

     - parameter text: The string contents of this comment.
     */
    public init(text: String) {
        self.text = text
    }
}

// MARK: - CDATASection

/**
 CDATA sections are used to escape blocks of text containing characters that
 would otherwise be regarded as markup. The only delimiter that is recognized
 in a CDATA section is the `"]]>"` string that ends the CDATA section. CDATA
 sections can not be nested. The primary purpose is for including material such
 as XML fragments, without needing to escape all the delimiters.

 The `text` property holds the text that is contained by the CDATA section.
 Note that this may contain characters that need to be escaped outside of CDATA
 sections.
 */
public class CDATASection: TextNode {

    // MARK: Node

    /// The `nodeType` of a `CDATASection` is `.cdataSection`.
    public static let nodeType: NodeType = .cdataSection

    /// The `nodeName` of a `CDATASection` is `#cdata-section`.
    public let nodeName: String = "#cdata-section"

    /// The `attributes` dictionary of a `CDATASection` is `nil`.
    public let attributes: [String : String]? = nil

    // MARK: TextNode

    /// The string contents of this CDATA section.
    public var text: String

    // MARK: Initializer

    /**
     Creates a new `CDATASection node.

     - parameter text: The string contents of this CDATA secion.
     */
    public init(text: String) {
        self.text = text
    }
}
