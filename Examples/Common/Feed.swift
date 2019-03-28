//
//  Feed.swift
//  MiniDOM Example
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
        let items = itemElements.compactMap({ Item(element: $0) })

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
