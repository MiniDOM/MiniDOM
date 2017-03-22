//
//  Path.swift
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

class PathSearch: Visitor {
    let path: [String]

    private let log = Log(level: .warn)

    private let pathAsSlice: ArraySlice<String>

    private(set) var matches: [Node] = []

    private var pathStack = ArraySlice<String>()

    init(path: [String]) {
        self.path = path
        self.pathAsSlice = ArraySlice<String>(path)

        log.debug("path = \(path)")
    }

    func beginVisit(_ element: Element) {
        push(element)
    }

    func endVisit(_ element: Element) {
        pop()
    }

    func visit(_ text: Text) {
        push(text)
        pop()
    }

    func visit(_ processingInstruction: ProcessingInstruction) {
        push(processingInstruction)
        pop()
    }

    func visit(_ comment: Comment) {
        push(comment)
        pop()
    }

    func visit(_ cdataSection: CDATASection) {
        push(cdataSection)
        pop()
    }

    private func push(_ node: Node) {
        pathStack.append(node.nodeName)
        log.debug("stack = \(pathStack)")

        if pathAsSlice == pathStack {
            log.debug("match found")
            matches.append(node)
        }
    }

    private func pop() {
        _ = pathStack.popLast()
    }
}

public extension Node {
    func evaluate(path: [String]) -> [Node] {
        let visitor = PathSearch(path: path)

        // Start with the children - exclude the current node in the search.
        // Otherwise, the current node (the object evaluate() is called on) must
        // be the first element in the path.
        for child in children {
            child.accept(visitor)
        }

        return visitor.matches
    }
}
