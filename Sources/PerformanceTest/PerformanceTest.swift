import ArgumentParser
import Foundation
import MiniDOM

struct PerformanceTest: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "MiniDOM performance testing",
        subcommands: [DocumentFromURL.self, DocumentFromData.self, StreamElements.self]
    )
}

struct Options: ParsableArguments {
    @Argument(help: "Input XML file")
    var inputFilename: String

    var inputURL: URL {
        URL(fileURLWithPath: inputFilename)
    }
}

struct DocumentFromURL: ParsableCommand {
    @OptionGroup
    var options: Options

    func run() throws {
        try measure("document-from-url: \(options.inputFilename)") {
            _ = Document(contentsOf: options.inputURL)
        }
    }
}

struct DocumentFromData: ParsableCommand {
    @OptionGroup
    var options: Options

    func run() throws {
        try measure("document-from-data: \(options.inputFilename)") {
            let data = try Data(contentsOf: options.inputURL)
            _ = Document(data: data)
        }
    }
}

struct StreamElements: ParsableCommand {
    @OptionGroup
    var options: Options

    func run() throws {
        try measure("stream-elements: \(options.inputFilename)") {
            SAXParser(contentsOf: options.inputURL)?.streamElements(
                to: { _ in true },
                filter: { _ in true }
            )
        }
    }
}
