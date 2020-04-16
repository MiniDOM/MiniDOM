# MiniDOM: Minimal XML DOM for Swift

[![Platform](https://img.shields.io/cocoapods/p/MiniDOM.svg)](https://minidom.github.io/Documentation)
![License](https://img.shields.io/cocoapods/l/MiniDOM.svg)

[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/MiniDOM.svg)](https://img.shields.io/cocoapods/v/MiniDOM.svg)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg)](https://github.com/Carthage/Carthage)
![Swift Package Manager Compatible](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange.svg)

[![codecov.io](https://codecov.io/gh/MiniDOM/MiniDOM/branch/master/graphs/badge.svg)](https://codecov.io/gh/MiniDOM/MiniDOM/branch/master)
![Documentation Status](https://minidom.github.io/Documentation/badge.svg)

## Introduction

MiniDOM is a minimal implementation of the Document Object Model interface. It is intended to be simpler than the full DOM but full-featured enough to be useful in most applications.

MiniDOM is fully [documented](https://minidom.github.io/Documentation/) and [unit tested](https://codecov.io/gh/MiniDOM/MiniDOM/). It can be used on iOS, macOS, watchOS, and tvOS. The library is released under the MIT license.

To parse an XML document, simply create a `Parser` object and call `parse()`:

```swift
import Foundation
import MiniDOM

func parseXML(url: URL) -> Document? {
    let parser = Parser(contentsOf: url)
    let result = parser?.parse()
    return result?.document
}
```

The resulting structure is a tree of objects implementing the `Node` protocol: `Document`, `Element`, `Text`, `ProcessingInstruction`, `Comment`, and `CDATASection`. Accessor methods and properties are provided that are similar to those in the DOM specification. DOM trees can be traversed using search methods, path-evaluation methods, or using the visitor design pattern. Each of these will be discussed in detail below.

## Installing

MiniDOM supports installation via the CocoaPods, Carthage, and the Swift Package Manager.

### CocoaPods

Add the following to your `Podfile`:

    pod 'MiniDOM'

### Carthage

Add the following to your `Cartfile`:

    github "MiniDOM/MiniDOM"

### Swift Package Manager

Add the following dependency to your `Package.swift` file:

    .package(url: "https://github.com/MiniDOM/MiniDOM/", from: "1.0.0")

### Dependencies

MiniDOM has no third-party dependencies. It only uses `Foundation` classes, including `XMLParser`. Unit tests are written using `XCUnit`.

## Path evaluation

MiniDOM provides a mechanism for traversing a document via a path. Call `Document.evaluate(path:)`, passing an array of strings representing element node names (`Node.nodeName`). For example, consider the following document:

```xml
<a id="1">
  <b id="2">
    <z id="3"/>
  </b>
  <c id="4">
    <z id="5"/>
  </c>
  <b id="6"/>
  <z id="7"/>
  <b id="8">
    <z id="9"/>
  </b>
</a>
```

Evaluating the path `["a", "b", "z"]` (by calling `document.evaluate(path: ["a", "b", "z"])`) will return an array of two `Element` objects representing the `<z>` elements with ID `3` and `9`.

## Visitor design pattern

The [Visitor Design Pattern](https://en.wikipedia.org/wiki/Visitor_pattern) is used throughout the MiniDOM library to implement algorithms that involve traversing the DOM tree. It provides a convenient mechanism to separate an algorithm from the object structure on which it operates. It allows operations to be added to the DOM structure without modifying the structures themselves.

A `Visitor` object is provided to `Node.accept(_:)` to start the traversal. The `Node` object calls the appropriate methods on the `Visitor` object before calling `Node.accept(_:)` on its child nodes, performing the recursive traversal.

The `Visitor` protocol defines methods that correspond to each of the `Node` types in the DOM. Types implementing the `Visitor` protocol do not need to deal with the actual traversal; its methods are called by the traversal algorithm provided by the DOM classes.

For a simple example of a visitor, see the `ElementSearch` class in `Search.swift`. For a more complex example of a visitor, see the `PrettyPrinter` class in `Formatter.swift`.

## Example

The following is taken from `MiniDOM.playground` in the root of the project. Feel free to open it up and experiment on your own.

### Parsing a document

We have an XML document saved in the resources section of the playground. It contains a snapshot of the EFF Updates RSS feed. We'll begin by parsing the document.

```swift
let url = Bundle.main.url(forResource: "eff-updates", withExtension: "rss")!
let parser = Parser(contentsOf: url)
let document = parser?.parse().document
```

### Walking through the document

The document's structure is something like this:

```xml
<rss>
    <channel>
        <title>...</title>
        <link>...</link>
        <description>...</description>
        <item>
            <title>...</title>
            <link>...</link>
            <description>...</description>
        </item>
        <item>...</item>
        ...
    </channel>
</rss>
```

Let's begin by getting the document element or root node of the document.

```swift
let rss = document?.documentElement
rss?.nodeName
```

**Result**
```
"rss"
```

The `<rss>` element should have one child: a `<channel>` element.

```swift
let channel = rss?.firstChildElement
channel?.nodeName
```

**Result**
```
"channel"
```

The `<channel>` element should have 50 `<item>` children.

```swift
let items = channel?.childElements(withName: "item")
items?.count
```

**Result**
```
50
```

Each of the `<item>` elements should have a `<title>` child.

```swift
let itemTitles = items?.flatMap { itemElement -> String? in
    let titleElement = itemElement.childElements(withName: "title").first
    return titleElement?.textValue
}
itemTitles
```

**Result**
```
0 "Stupid Patent of the Month: Storing Files in Folders"
1 "NAFTA Renegotiation Will Resurrect Failed TPP Proposals"
2 "New Report Aims to Help Criminal Defense Attorneys Challenge Secretive Government Hacking"
3 "The Most Powerful Single Click in Your Facebook Privacy Settings"
4 "Repealing Broadband Privacy Rules, Congress Sides with the Cable and Telephone Industry"
...
```

There are `<link>` elements that are children of the `<channel>` element, and that are children of each of the `<item>` elements. We can find all of them.

```swift
let linkElementsFromDocument = document?.elements(withTagName: "link")
let linkURLsFromDocument = linkElementsFromDocument?.flatMap { $0.textValue }
linkURLsFromDocument
```

**Result**
```
0 "https://www.eff.org/rss/updates.xml"
1 "https://www.eff.org/deeplinks/2017/03/stupid-patent-month-storing-files-folders"
2 "https://www.eff.org/deeplinks/2017/03/nafta-renegotiation-will-resurrect-failed-tpp-proposals"
3 "https://www.eff.org/deeplinks/2017/03/eff-says-no-so-called-moral-rights-copyright-expansion"
4 "https://www.eff.org/deeplinks/2017/03/new-report-aims-help-criminal-defense-attorneys-challenge-secretive-government"
5 "https://www.eff.org/deeplinks/2017/03/most-powerful-single-click-your-facebook-privacy-settings"
...
```

### Path evaluation

The `<item>` children of the `<channel>` element should each have a `<link>` child. Using a path expression, we can collect all of the text children of the `<link>` elements under the `<channel>` element.

```swift
let linkTextNodesViaPath = document?.evaluate(path: ["rss", "channel", "item", "link", "#text"])
let linkURLsViaPath = linkTextNodesViaPath?.flatMap { $0.nodeValue }
linkURLsViaPath
```

**Result**
```
0 "https://www.eff.org/deeplinks/2017/03/stupid-patent-month-storing-files-folders"
1 "https://www.eff.org/deeplinks/2017/03/nafta-renegotiation-will-resurrect-failed-tpp-proposals"
2 "https://www.eff.org/deeplinks/2017/03/eff-says-no-so-called-moral-rights-copyright-expansion"
3 "https://www.eff.org/deeplinks/2017/03/new-report-aims-help-criminal-defense-attorneys-challenge-secretive-government"
4 "https://www.eff.org/deeplinks/2017/03/most-powerful-single-click-your-facebook-privacy-settings"
...
```

### Visitor

We can collect all of the `<title>` elements in the document using a visitor.

```swift
class TitleCollector: Visitor {
    var titles: [String] = []

    public func beginVisit(_ element: Element) {
        if element.tagName == "title", let title = element.textValue {
            titles.append(title)
        }
    }
}

let titleCollector = TitleCollector()
document?.accept(titleCollector)
titleCollector.titles
```

**Result**
```
0 "Deeplinks"
1 "Stupid Patent of the Month: Storing Files in Folders"
2 "NAFTA Renegotiation Will Resurrect Failed TPP Proposals"
3 "New Report Aims to Help Criminal Defense Attorneys Challenge Secretive Government Hacking"
4 "The Most Powerful Single Click in Your Facebook Privacy Settings"
5 "Repealing Broadband Privacy Rules, Congress Sides with the Cable and Telephone Industry"
```

## Issues and Contributions

Please [report](https://github.com/MiniDOM/MiniDOM/issues) any issues you find.

Pull requests are welcome. Please make sure any additions are documented and unit tested. We aim to maintain 100% documentation and test coverage.

