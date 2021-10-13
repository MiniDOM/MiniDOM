//
//  NodeStack.swift
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

class NodeStack {

    enum Error: Swift.Error {
        case invalidState
    }

    var first: Node? {
        return stack.first
    }

    private var stack: ArraySlice<Node> = []

    func append(node: Node) throws {
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

    func append(string: String, nodeType: TextNode.Type) throws {
        let node = stack.popLast()

        if var parent = node as? ParentNode {
            if var text = parent.children.last as? Text {
                text.append(string)
                parent.children[parent.children.count - 1] = text
            }
            else {
                parent.children.append(nodeType.init(text: string))
            }
            stack.append(parent)
        }
        else if var text = node as? TextNode {
            text.append(string)
            stack.append(text)
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
