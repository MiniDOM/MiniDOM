//
//  NodeList.swift
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

public extension Sequence where Element == Node {

    /**
     Returns only the nodes of the given type.

     - parameter type: The target type.

     - returns: All members of the receiver that are of the given type.
     */
    func only<T: Node>(ofType type: T.Type) -> [T] {
        return compactMap { $0 as? T }
    }

    /**
     Returns the first node of the given type.

     - parameter type: The target type.

     - returns: The first node of the given type.
     */
    func first<T: Node>(ofType type: T.Type) -> T? {
        return first(where: { $0.nodeType == type.nodeType }) as? T
    }

    /**
     Returns the objects from the receiver with the given node name.

     - parameter name: The node name to find.

     - returns: The nodes from the receiver with the given node name.
     */
    func nodes(withName name: String) -> [Node] {
        return filter({ $0.nodeName == name })
    }

    /**
     Returns the `Element` objects from the receiver with the given node name.

     - parameter name: The node name to find.

     - returns: The elements from the receiver with the given node name.
     */
    func elements(withName name: String) -> [MiniDOM.Element] {
        let elements = only(ofType: MiniDOM.Element.self)
        return elements.filter({ $0.nodeName == name })
    }

    /**
     Returns the first `Element` object from the receiver with the given node name.

     - parameter name: The node name to find.

     - returns: The first element from the receiver with the given node name.
     */
    func firstElement(withName name: String) -> MiniDOM.Element? {
        lazy.compactMap { $0 as? MiniDOM.Element }.first(where: { $0.nodeName == name })
    }
}
