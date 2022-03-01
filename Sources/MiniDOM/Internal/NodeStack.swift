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
        return stack.peek()
    }

    private var stack = Stack()

    func append(node: Node) throws {
        if node.isParentNode {
            stack.push(node)
        }
        else if var parent = stack.pop(), parent.isParentNode {
            // We know this is a parent node (see above), so this will always result in an append operation
            parent.appendIfParent(child: node)
            stack.push(parent)
        }
        else {
            throw Error.invalidState
        }
    }

    func append(string: String, nodeType: TextNode.Type) throws {
        let node = stack.pop()

        if var parent = node as? ParentNode {
            if var text = parent.children.last as? Text {
                text.append(string)
                parent.children[parent.children.count - 1] = text
            }
            else {
                parent.children.append(nodeType.init(text: string))
            }
            stack.push(parent)
        }
        else if var text = node as? TextNode {
            text.append(string)
            stack.push(text)
        }
        else {
            throw Error.invalidState
        }
    }

    func popAndAppend() throws {
        guard let child = stack.pop() else {
            throw Error.invalidState
        }

        if var parent = stack.pop(), parent.isParentNode {
            // We know this is a parent node (see above), so this will always result in an append operation
            parent.appendIfParent(child: child)
            stack.push(parent)
        }
        else if child.isParentNode {
            stack.push(child)
        }
        else {
            throw Error.invalidState
        }
    }
}

private class Stack {

    private class Box {
        var node: Node
        var next: Box?

        init(node: Node, next: Box?) {
            self.node = node
            self.next = next
        }
    }

    private var top: Box? = nil

    private(set) var count: Int = 0

    required init() { }

    func push(_ node: Node) {
        let box = Box(node: node, next: top)
        top = box

        count += 1
    }

    func pop() -> Node? {
        if count == 0 {
            return nil
        }

        let result = top

        top = result?.next
        count -= 1

        return result?.node
    }

    func peek() -> Node? {
        return top?.node
    }
}
