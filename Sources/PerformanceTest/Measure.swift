import Foundation

func _getrusage() -> rusage {
    var value = rusage()
    guard getrusage(RUSAGE_SELF, &value) == 0 else {
        fatalError("Call to getrusage() failed with errno \(errno)")
    }

    return value
}

extension TimeInterval {
    init(_ t: timeval) {
        self = TimeInterval(t.tv_sec) + (TimeInterval(t.tv_usec) / 1_000_000)
    }
}

extension rusage {
    var userTimeUsed: TimeInterval {
        return TimeInterval(ru_utime)
    }

    var systemTimeUsed: TimeInterval {
        return TimeInterval(ru_stime)
    }
}

extension rusage: CustomStringConvertible {
    public var description: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal

        func format(_ value: Int) -> String {
            return formatter.string(from: NSNumber(value: value)) ?? "(error)"
        }

        return [
            "ru_maxrss    \(format(ru_maxrss))",
            "ru_ixrss     \(format(ru_ixrss))",
            "ru_idrss     \(format(ru_idrss))",
            "ru_isrss     \(format(ru_isrss))",
            "ru_minflt    \(format(ru_minflt))",
            "ru_majflt    \(format(ru_majflt))",
            "ru_nswap     \(format(ru_nswap))",
            "ru_inblock   \(format(ru_inblock))",
            "ru_oublock   \(format(ru_oublock))",
            "ru_msgsnd    \(format(ru_msgsnd))",
            "ru_msgrcv    \(format(ru_msgrcv))",
            "ru_nsignals  \(format(ru_nsignals))",
            "ru_nvcsw     \(format(ru_nvcsw))",
            "ru_nivcsw    \(format(ru_nivcsw))",
        ].map { "\t\($0)" }.joined(separator: "\n")
    }
}

func measure(_ description: String, worker: () throws -> Void) throws {
    let start = _getrusage()
    defer {
        let end = _getrusage()

        let ds = String(format: "%.6g", end.systemTimeUsed - start.systemTimeUsed)
        let du = String(format: "%.6g", end.userTimeUsed - start.userTimeUsed)

        print("ru_maxrss: \(end.ru_maxrss - start.ru_maxrss)")

        print("\(description) completed (system: \(ds) sec, user: \(du) sec)")
        print(end.description)
    }

    try worker()
}
