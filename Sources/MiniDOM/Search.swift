//
//  Search.swift
//  MiniDOM
//
//  Copyright 2017-2020 Anodized Software, Inc.
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

class ElementSearch: Visitor {

    let predicate: (Element) -> Bool

    var elements: [Element] = []

    init(predicate: @escaping (Element) -> Bool) {
        self.predicate = predicate
    }

    func beginVisit(_ element: Element) {
        if predicate(element) {
            elements.append(element)
        }
    }
}

class ElementPathSearch: ElementSearch, LazyVisitor {

    let filter: ((Element) -> Bool)?

    private(set) var keepVisiting = true

    init(predicate: @escaping (Element) -> Bool, filter: ((Element) -> Bool)? = nil) {
        self.filter = filter
        super.init(predicate: predicate)
    }

    func shouldVisit(element: Element) -> Bool {
        guard let filter = filter else {
            return true
        }
        return filter(element)
    }

    override func beginVisit(_ element: Element) {
        guard keepVisiting else {
            return
        }
        elements.append(element)
        keepVisiting = !predicate(element)
    }

    func endVisit(_ element: Element) {
        if keepVisiting {
            elements.removeLast()
        }
    }
}

public extension Document {
    /**
     Traverses the document tree, collecting `Element` nodes with the specified
     tag name from anywhere in the document.

     - parameter name: Collect elements with this tag name.

     - returns: An array of elements with the specified tag name.
     */
    final func elements(withTagName name: String) -> [Element] {
        return elements(where: { $0.tagName == name })
    }

    /**
     Traverses the document tree, collecting `Element` nodes that satisfy the
     given predicate from anywhere in the document.

     - parameter predicate: A closure that takes an element as its argument and
     returns a Boolean value indicating whether the element should be included
     in the returned array.

     - returns: An array of the elements that `predicate` allowed.
     */
    final func elements(where predicate: @escaping (Element) -> Bool) -> [Element] {
        let visitor = ElementSearch(predicate: predicate)
        documentElement?.accept(visitor)
        return visitor.elements
    }

    /**
     Traverses the document tree, until an `Element` node is encountererd that satisfies
     the given predicate anywhere in the document.

     - parameter predicate: A closure that takes an element as its argument and
     returns a Boolean value indicating whether the element has been found.

     - returns: The first element that matched `predicate`.
     */
    final func element(where predicate: @escaping (Element) -> Bool) -> Element? {
        return pathToElement(where: predicate)?.last
    }

    /**
     Traverses the document tree, until an `Element` node is encountererd that satisfies
     the given predicate anywhere in the document.

     - parameter predicate: A closure that takes an element as its argument and
     returns a Boolean value indicating whether the element has been found.

     - parameter filter: An optional closure that takes an element as its argument and
     returns a Boolean value indicating whether the subtree rooted at that element
     should be traversed. For example, there may be certain attributes that indicate
     traversing there is no element in the subtree that could possibly match `predicate`.

     - returns: The an array of `Element` nodes, which is the traversal path taken to find the
     first `Element` matching `predicate`. The `last` element is the matching `Element` itself.
     */
    final func pathToElement(where predicate: @escaping (Element) -> Bool, filter: ((Element) -> Bool)? = nil) -> [Element]? {
        let visitor = ElementPathSearch(predicate: predicate, filter: filter)
        acceptLazy(visitor)
        return visitor.elements.isEmpty ? nil : visitor.elements
    }
}
