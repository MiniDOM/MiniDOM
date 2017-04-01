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
