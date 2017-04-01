//
//  Feed.swift
//  MiniDOM Example
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
import MiniDOM

struct Feed {
    let title: String
    let items: [Item]

    init?(document: Document) {
        var document = document
        document.normalize()

        guard let title = document.evaluate(path: ["rss", "channel", "title", "#text"]).first(ofType: Text.self)?.nodeValue else {
            return nil
        }

        let itemElements = document.evaluate(path: ["rss", "channel", "item"]).only(ofType: Element.self)
        let items = itemElements.flatMap({ Item(element: $0) })

        self.title = title
        self.items = items
    }
}

struct Item {
    let title: String
    let link: URL

    init?(element: Element) {
        guard let linkText = element.evaluate(path: ["link", "#text"]).first?.nodeValue,
              let link = URL(string: linkText),
              let title = element.evaluate(path: ["title", "#text"]).first?.nodeValue
        else {
            return nil
        }

        self.title = title
        self.link = link
    }
}
