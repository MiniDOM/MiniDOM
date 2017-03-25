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

/**
 Returns only the nodes of the specified type in the specified array.
 
 - parameter nodes: An array of `Node` objects to filter.
 
 - parameter type: The target type.
 
 - returns: All members of the specified array that are of the specified type.
 */
public func only<T: Node>(nodes: [Node], ofType type: T.Type) -> [T] {
    return nodes.flatMap({ $0 as? T })
}

/**
 Returns the first node of the specified type in the specified array.
 
 - parameter nodes: An array of `Node` objects to search.
 
 - parameter type: The target type.
 
 - returns: The first node of the specified type.
 */
public func first<T: Node>(in nodes: [Node], ofType type: T.Type) -> T? {
    return nodes.first(where: { $0.nodeType == type.nodeType }) as? T
}
