//
//  NodeList.swift
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

public extension Array where Element == Node {

    /**
     Returns only the nodes of the given type.

     - parameter type: The target type.

     - returns: All members of the receiver that are of the given type.
     */
    public func only<T: Node>(ofType type: T.Type) -> [T] {
        return self.compactMap { $0 as? T }
    }

    /**
     Returns the first node of the given type.

     - parameter type: The target type.

     - returns: The first node of the given type.
     */
    public func first<T: Node>(ofType type: T.Type) -> T? {
        return first(where: { $0.nodeType == type.nodeType }) as? T
    }

    /**
     Returns the objects from the receiver with the given node name.
     
     - parameter name: The node name to find.
     
     - returns: The nodes from the receiver with the given node name.
     */
    public func nodes(withName name: String) -> [Node] {
        return filter({ $0.nodeName == name })
    }

    /**
     Returns the `Element` objects from the receiver with the given node name.
     
     - parameter name: The node name to find.
     
     - returns: The elements from the receiver with the given node name.
     */
    public func elements(withName name: String) -> [MiniDOM.Element] {
        let elements = only(ofType: MiniDOM.Element.self)
        return elements.filter({ $0.nodeName == name })
    }
}
