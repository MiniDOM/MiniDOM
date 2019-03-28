//
//  Search.swift
//  MiniDOM
//
//  Copyright 2017-2019 Anodized Software, Inc.
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
    private(set) var elements: [Element] = []

    let predicate: (Element) -> Bool

    init(predicate: @escaping (Element) -> Bool) {
        self.predicate = predicate
    }

    func beginVisit(_ element: Element) {
        if predicate(element) {
            elements.append(element)
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
}
