//
//  Search.swift
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
    public final func elements(withTagName name: String) -> [Element] {
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
    public final func elements(where predicate: @escaping (Element) -> Bool) -> [Element] {
        let visitor = ElementSearch(predicate: predicate)
        documentElement?.accept(visitor)
        return visitor.elements
    }
}
