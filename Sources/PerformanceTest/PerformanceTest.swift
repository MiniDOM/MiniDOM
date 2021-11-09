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
    @Argument(help: "Input XML files")
    var inputFiles: [FileArgument]
}

struct FileArgument: ExpressibleByArgument, Decodable {
    var url: URL

    init?(argument: String) {
        self.url = URL(fileURLWithPath: argument, isDirectory: false)
    }
}

protocol Subcommand: ParsableCommand {
    var options: Options { get }
}

extension Subcommand {
    var inputURLs: [URL] {
        options.inputFiles.map { $0.url.absoluteURL }
    }

    func printIfVerbose(_ string: String) {
        print(string)
    }

    func printOptions() {
        print(options)
    }
}

struct DocumentFromURL: Subcommand {
    @OptionGroup
    var options: Options

    func run() throws {
        try measure("document-from-url: all") {
            for url in inputURLs {
                try measure("document-from-url: \(url)") {
                    _ = Document(contentsOf: url)
                }
            }
        }
    }
}

struct DocumentFromData: Subcommand {
    @OptionGroup
    var options: Options

    func run() throws {
        try measure("document-from-data: all") {
            for url in inputURLs {
                try measure("document-from-data: \(url)") {
                    let data = try Data(contentsOf: url)
                    _ = Document(data: data)
                }
            }
        }
    }
}

struct StreamElements: Subcommand {
    @OptionGroup
    var options: Options

    func run() throws {
        try measure("stream-elements: all") {
            for url in inputURLs {
                try measure("stream-elements: \(url)") {
                    SAXParser(contentsOf: url)?.streamElements(to: { _ in true }, filter: { _ in true })
                }
            }
        }
    }
}

func measure(_ description: String, worker: () throws -> Void) throws {
    let start = clock()
    defer {
        let end = clock()
        let delta = timeDelta(start, end)
        print("\(description) completed in \(delta) seconds")
    }

    print("Starting \(description)")
    try worker()
}

func timeDelta(_ t1: clock_t, _ t2: clock_t) -> TimeInterval {
    let delta = Int64(t2) - Int64(t1)
    return TimeInterval(delta) / TimeInterval(CLOCKS_PER_SEC)
}
