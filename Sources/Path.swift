//
//  Path.swift
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

public extension Node {
    /**
     Selects nodes based on a path relative to this node. For example, in the
     following document:

     ```xml
     <a id="1">
       <b id="2">
         <c id="3"/>
       </b>
       <c id="4">
         <d id="5"/>
       </c>
     </a>
     ```

     evaluating the path `["a", "b", "c"]` relative to the document would select
     the `<c>` element with `id="3"` but not the `<c>` element with `id="4"`.

     In this example, starting at the document object (the parent of the root
     `<a>` element), select all children with `nodeName == "a"`. From that set
     of nodes (with `nodeName == "a"`), select all children with `nodeName ==
     "b"`. Finally, from that set of nodes (with `nodeName == "b"` that are
     children of nodes with `nodeName == "a"`), select all children with
     `nodeName == "c"`.

     - parameter path: An array of strings, each representing a `nodeName` in
     the path.

     - returns: An array of nodes corresponding to the specified path, relative
     to this node.
     */

    func evaluate(path: [String]) -> [Node] {
        var selected: [Node] = [self]

        for name in path {
            selected = selected.flatMap({ $0.children(withName: name) })
        }

        return selected
    }
}
