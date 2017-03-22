//
//  Visitor.swift
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

// MARK: - Visitor Protocol

public protocol Visitor {
    func beginVisit(_ document: Document)

    func endVisit(_ document: Document)

    func beginVisit(_ element: Element)

    func endVisit(_ element: Element)

    func visit(_ text: Text)

    func visit(_ processingInstruction: ProcessingInstruction)

    func visit(_ comment: Comment)

    func visit(_ cdataSection: CDATASection)
}

// Instead of making the functions optional, just provide a default empty 
// implementation of each of the functions.
public extension Visitor {
    func beginVisit(_ document: Document) {}

    func endVisit(_ document: Document) {}

    func beginVisit(_ element: Element) {}

    func endVisit(_ element: Element) {}

    func visit(_ text: Text) {}

    func visit(_ processingInstruction: ProcessingInstruction) {}

    func visit(_ comment: Comment) {}

    func visit(_ cdataSection: CDATASection) {}
}

// MARK: - Visitable Protocol

public protocol Visitable {
    func accept(_ visitor: Visitor)
}

extension Document: Visitable {
    public func accept(_ visitor: Visitor) {
        visitor.beginVisit(self)

        for child in children {
            child.accept(visitor)
        }

        visitor.endVisit(self)
    }
}

extension Element: Visitable {
    public func accept(_ visitor: Visitor) {
        visitor.beginVisit(self)

        for child in children {
            child.accept(visitor)
        }

        visitor.endVisit(self)
    }
}

extension Text: Visitable {
    public func accept(_ visitor: Visitor) {
        visitor.visit(self)
    }
}

extension ProcessingInstruction: Visitable {
    public func accept(_ visitor: Visitor) {
        visitor.visit(self)
    }
}

extension Comment: Visitable {
    public func accept(_ visitor: Visitor) {
        visitor.visit(self)
    }
}

extension CDATASection: Visitable {
    public func accept(_ visitor: Visitor) {
        visitor.visit(self)
    }
}
