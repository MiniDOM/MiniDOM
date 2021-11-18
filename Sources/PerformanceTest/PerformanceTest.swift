//
//  PerformanceTest.swift
//  PerformanceTest
//
//  Copyright 2017-2021 Anodized Software, Inc.
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

    @Option(name: .long, help: "Metrics are recorded to this file")
    var metricsFilename: String

    var inputURL: URL {
        URL(fileURLWithPath: inputFilename)
    }

    var metricsURL: URL {
        URL(fileURLWithPath: metricsFilename)
    }
}

protocol Subcommand: ParsableCommand {
    var options: Options { get }
}

extension Subcommand {
    func write(metrics: Measurement, subcommand: String) throws {
        let header = ["subcommand", "xmlFilename"] + Measurement.fieldNames
        let headerLine = header.joined(separator: ",")

        let fieldValues = [subcommand, options.inputFilename] + metrics.fieldValues
        let fieldLine = fieldValues.joined(separator: ",")

        try write(header: headerLine, values: fieldLine)
    }

    private func write(header: String, values: String) throws {
        // If the file exists...
        if let fh = try? FileHandle(forWritingTo: options.metricsURL) {
            defer {
                fh.closeFile()
            }

            // Go to the end of the file, write a newline then the values line
            fh.seekToEndOfFile()
            fh.write(("\n" + values).data(using: .utf8)!)
        }
        // If the file doesn't exist
        else {
            // Write the entire file: header line then the values line
            let data = [header, values].joined(separator: "\n").data(using: .utf8)!
            try data.write(to: options.metricsURL)
        }
    }
}

struct DocumentFromURL: Subcommand {
    @OptionGroup
    var options: Options

    func run() throws {
        let m = measure {
            _ = Document(contentsOf: options.inputURL)
        }
        try write(metrics: m, subcommand: "document-from-url")
    }
}

struct DocumentFromData: Subcommand {
    @OptionGroup
    var options: Options

    func run() throws {
        let m = measure {
            let data = try? Data(contentsOf: options.inputURL)
            _ = Document(data: data)
        }
        try write(metrics: m, subcommand: "document-from-data")
    }
}

struct StreamElements: Subcommand {
    @OptionGroup
    var options: Options

    func run() throws {
        let m = measure {
            SAXParser(contentsOf: options.inputURL)?.streamElements(
                to: { _ in true },
                filter: { _ in true }
            )
        }
        try write(metrics: m, subcommand: "stream-elements")
    }
}
