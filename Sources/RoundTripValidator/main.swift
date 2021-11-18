//
//  main.swift
//  RoundTripValidator
//
//  Copyright 2017-2020 Anodized Software, Inc.
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

private func printError(_ message: CustomStringConvertible) {
    fputs(message.description, stderr)
}

enum RoundTripValidatorError: Error {
    case incorrectArguments
    case unableToParseInput
    case unableToDecodeData
    case couldNotDumpString
    case inputAndOutputDoNotMatch
}

func main(args: [String]) throws -> Int32 {
    guard args.count == 2 else {
        throw RoundTripValidatorError.incorrectArguments
    }

    let filename = args[1]
    let sourceURL = URL(fileURLWithPath: filename)

    let inputData = try Data(contentsOf: sourceURL)
    guard let inputString = String(data: inputData, encoding: .isoLatin1) else {
        throw RoundTripValidatorError.unableToDecodeData
    }

    guard let document = Document(string: inputString) else {
        throw RoundTripValidatorError.unableToParseInput
    }

    let outputString = document.dump()
    print(outputString)

    if inputString != outputString {
        throw RoundTripValidatorError.inputAndOutputDoNotMatch
    }

    return 0
}

do {
    exit(try main(args: CommandLine.arguments))
}
catch {
    printError("\(error)")
    exit(1)
}
