/*:
 # MiniDOM Examples
 
 This playground shows some examples using MiniDOM to process XML content.
 
 We begin by importing the `MiniDOM` library.
 */
import MiniDOM

/*:
 We have an XML document saved in the resources section of this playground. It contains a snapshot of the EFF Updates RSS feed. We'll begin by parsing the document.
 */
let url = Bundle.main.url(forResource: "eff-updates", withExtension: "rss")!
let document = Document(url: url)

/*:
 The document's structure is something like this:
 
 ```
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
 */
let rss = document?.documentElement
rss?.nodeName

/*:
 The `<rss>` element should have one child: a `<channel>` element.
 */
let channel = rss?.firstChildElement
channel?.nodeName

/*:
 The `<channel>` element should have 50 `<item>` children.
 */
let items = channel?.childElements(withName: "item")
items?.count

/*:
 Each of the `<item>` elements should have a `<title>` child.
 */
let itemTitles = items?.compactMap { itemElement -> String? in
    let titleElement = itemElement.childElements(withName: "title").first
    return titleElement?.textValue
}
itemTitles

/*:
 There are `<link>` elements that are children of the `<channel>` element, and that are children of each of the `<item>` elements. We can find all of them.
 */
let linkElementsFromDocument = document?.elements(withTagName: "link")
let linkURLsFromDocument = linkElementsFromDocument?.compactMap { $0.textValue }
linkURLsFromDocument

/*:
 The `<item>` children of the `<channel>` element should each have a `<link>` child. Using a path expression, we can collect al0 "https://www.eff.org/rss/updates.xml"l of the text children of the `<link>` elements under the `<channel>` element.
 */
let linkTextNodesViaPath = document?.evaluate(path: ["rss", "channel", "item", "link", "#text"])
let linkURLsViaPath = linkTextNodesViaPath?.compactMap { $0.nodeValue }
linkURLsViaPath

/*:
 We can collect all of the `<title>` elements in the document using a visitor.
 */
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
