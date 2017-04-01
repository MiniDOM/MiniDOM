//
//  Feed.swift
//  MiniDOM Example
//
//  Created by Paul Calnan on 3/30/17.
//  Copyright © 2017 Anodized Software, Inc. All rights reserved.
//

import Foundation
import MiniDOM

struct Feed {
    let title: String
    let items: [Item]

    init?(document: Document) {
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

    private static func text(from nodes: [Node]) -> [String] {
        return nodes.only(ofType: Text.self).flatMap({ $0.nodeValue })
    }

    init?(element: Element) {
        let linkText = Item.text(from: element.evaluate(path: ["link", "#text"])).joined(separator: "")
        guard let link = URL(string: linkText) else {
            return nil
        }

        let title = Item.text(from: element.evaluate(path: ["title", "#text"])).joined(separator: " ")

        self.title = title
        self.link = link
    }
}
