//
//  Measurement.swift
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

import Darwin
import Foundation

func measure(_ block: () -> Void) -> Measurement {
    let start = Measurement()
    block()
    let end = Measurement()

    return Measurement(start: start, end: end)
}

struct Measurement {
    var timestamp: Date

    var timeOfDay: timeval

    var rusage: rusage

    fileprivate init() {
        var rusage = Darwin.rusage()
        guard getrusage(RUSAGE_SELF, &rusage) == 0 else {
            fatalError("Call to getrusage() failed with errno \(errno)")
        }

        var timeOfDay = Darwin.timeval()
        guard gettimeofday(&timeOfDay, nil) == 0 else {
            fatalError("Call to gettimeofday() failed with errno \(errno)")
        }

        self.init(timestamp: Date(), rusage: rusage, timeOfDay: timeOfDay)
    }

    private init(timestamp: Date, rusage: rusage, timeOfDay: timeval) {
        self.timestamp = timestamp
        self.rusage = rusage
        self.timeOfDay = timeOfDay
    }

    fileprivate init(start: Measurement, end: Measurement) {
        let m = end - start
        self.init(timestamp: m.timestamp, rusage: m.rusage, timeOfDay: m.timeOfDay)
    }
}

extension Measurement {
    static func -(lhs: Measurement, rhs: Measurement) -> Measurement {
        return Measurement(
            timestamp: min(lhs.timestamp, rhs.timestamp),
            rusage: lhs.rusage - rhs.rusage,
            timeOfDay: lhs.timeOfDay - rhs.timeOfDay
        )
    }
}

extension Measurement {
    static var fieldNames: [String] {
        [
            "timestamp",
            "wallClock",
            "ru_utime",
            "ru_stime",
            "ru_maxrss",
            "ru_ixrss",
            "ru_idrss",
            "ru_isrss",
            "ru_minflt",
            "ru_majflt",
            "ru_nswap",
            "ru_inblock",
            "ru_oublock",
            "ru_msgsnd",
            "ru_msgrcv",
            "ru_nsignals",
            "ru_nvcsw",
            "ru_nivcsw",
        ]
    }

    var fieldValues: [String] {
        func format(_ timeInterval: TimeInterval) -> String {
            return timeInterval.description
        }

        func format(_ integer: Int) -> String {
            return integer.description
        }

        func format(_ date: Date) -> String {
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
            df.locale = Locale(identifier: "en_US_POSIX")

            return df.string(from: date)
        }

        return [
            format(timestamp),
            format(timeOfDay.asTimeInterval),
            format(rusage.ru_utime.asTimeInterval),
            format(rusage.ru_stime.asTimeInterval),
            format(rusage.ru_maxrss),
            format(rusage.ru_ixrss),
            format(rusage.ru_idrss),
            format(rusage.ru_isrss),
            format(rusage.ru_minflt),
            format(rusage.ru_majflt),
            format(rusage.ru_nswap),
            format(rusage.ru_inblock),
            format(rusage.ru_oublock),
            format(rusage.ru_msgsnd),
            format(rusage.ru_msgrcv),
            format(rusage.ru_nsignals),
            format(rusage.ru_nvcsw),
            format(rusage.ru_nivcsw),
        ]
    }
}

// MARK: - rusage

extension rusage {
    static func -(lhs: rusage, rhs: rusage) -> rusage {
        return rusage(
            ru_utime:    lhs.ru_utime    - rhs.ru_utime,
            ru_stime:    lhs.ru_stime    - rhs.ru_stime,
            ru_maxrss:   lhs.ru_maxrss   - rhs.ru_maxrss,
            ru_ixrss:    lhs.ru_ixrss    - rhs.ru_ixrss,
            ru_idrss:    lhs.ru_idrss    - rhs.ru_idrss,
            ru_isrss:    lhs.ru_isrss    - rhs.ru_isrss,
            ru_minflt:   lhs.ru_minflt   - rhs.ru_minflt,
            ru_majflt:   lhs.ru_majflt   - rhs.ru_majflt,
            ru_nswap:    lhs.ru_nswap    - rhs.ru_nswap,
            ru_inblock:  lhs.ru_inblock  - rhs.ru_inblock,
            ru_oublock:  lhs.ru_oublock  - rhs.ru_oublock,
            ru_msgsnd:   lhs.ru_msgsnd   - rhs.ru_msgsnd,
            ru_msgrcv:   lhs.ru_msgrcv   - rhs.ru_msgrcv,
            ru_nsignals: lhs.ru_nsignals - rhs.ru_nsignals,
            ru_nvcsw:    lhs.ru_nvcsw    - rhs.ru_nvcsw,
            ru_nivcsw:   lhs.ru_nivcsw   - rhs.ru_nivcsw)
    }
}

// MARK: - timeval

extension timeval {
    static func -(lhs: timeval, rhs: timeval) -> timeval {
        return timeval(tv_sec: lhs.tv_sec - rhs.tv_sec, tv_usec: lhs.tv_usec - rhs.tv_usec)
    }

    var asTimeInterval: TimeInterval {
        TimeInterval(tv_sec) + (TimeInterval(tv_usec) / 1_000_000)
    }
}

