# MiniDOM: Minimal XML DOM for Swift

[![Build Status](https://api.travis-ci.org/MiniDOM/MiniDOM.svg?branch=master)](https://travis-ci.org/MiniDOM/MiniDOM)
[![codecov.io](https://codecov.io/gh/MiniDOM/MiniDOM/branch/master/graphs/badge.svg)](https://codecov.io/gh/MiniDOM/MiniDOM/branch/master)
![Documentation Status](https://minidom.github.io/Documentation/badge.svg)

MiniDOM is a minimal XML DOM parser for Swift. It has no dependencies other than Foundation. It is built upon Foundation's `XMLParser` class. It is simple and easy to use, yet powerful enough for most applications.

To parse an XML document, simply create a `Parser` object and call `parse()`:

```swift
import Foundation
import MiniDOM

func parseXML(url: URL) -> Document? {
    guard let parser = Parser(contentsOf: url) else {
        return nil
    }

    let result = parser.parse()
    return result.document
}
```

