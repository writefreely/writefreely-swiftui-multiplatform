// Credit for much of this class: https://steipete.com/posts/logging-in-swift/

import Foundation
import os
import OSLog

protocol LogWriter {
    func log(_ message: String, withSensitiveInfo privateInfo: String?, level: OSLogType)
    func logCrashAndSetFlag(error: Error)
}

@available(iOS 15, *)
protocol LogReader {
    func fetchLogs() -> [String]
}

final class Logging {

    private let logger: Logger
    private let subsystem = Bundle.main.bundleIdentifier!

    init(for category: String = "") {
        self.logger = Logger(subsystem: subsystem, category: category)
    }

}

extension Logging: LogWriter {

    func log(
        _ message: String,
        withSensitiveInfo privateInfo: String? = nil,
        level: OSLogType = .default
    ) {
        if let privateInfo = privateInfo {
            logger.log(level: level, "\(message): \(privateInfo, privacy: .sensitive)")
        } else {
            logger.log(level: level, "\(message)")
        }
    }

    func logCrashAndSetFlag(error: Error) {
        let errorDescription = error.localizedDescription
        UserDefaults.shared.set(true, forKey: WFDefaults.didHaveFatalError)
        UserDefaults.shared.set(errorDescription, forKey: WFDefaults.fatalErrorDescription)
        logger.log(level: .error, "\(errorDescription)")
        fatalError(errorDescription)
    }

}

extension Logging: LogReader {

    @available(iOS 15, *)
    func fetchLogs() -> [String] {
        var logs: [String] = []

        do {
            let osLog = try getLogEntries()
            for logEntry in osLog {
                let formattedEntry = formatEntry(logEntry)
                logs.append(formattedEntry)
            }
        } catch {
            logs.append("Could not fetch logs")
        }

        return logs
    }

    @available(iOS 15, *)
    private func getLogEntries() throws -> [OSLogEntryLog] {
        let logStore = try OSLogStore(scope: .currentProcessIdentifier)
        let oneHourAgo = logStore.position(date: Date().addingTimeInterval(-3600))
        let allEntries = try Array(logStore.__entriesEnumerator(position: oneHourAgo, predicate: nil))
        return allEntries
            .compactMap { $0 as? OSLogEntryLog }
            .filter { $0.subsystem == subsystem }
    }

    @available(iOS 15, *)
    private func formatEntry(_ logEntry: OSLogEntryLog) -> String {
        /// The desired format is:
        /// `date [process/category] LEVEL: composedMessage (threadIdentifier)`
        var level: String = ""
        switch logEntry.level {
        case .debug:
            level = "DEBUG"
        case .info:
            level = "INFO"
        case .notice:
            level = "NOTICE"
        case .error:
            level = "ERROR"
        case .fault:
            level = "FAULT"
        default:
            level = "UNDEFINED"
        }
        // swiftlint:disable:next line_length
        return "\(logEntry.date) [\(logEntry.process)/\(logEntry.category)] \(level): \(logEntry.composedMessage) (\(logEntry.threadIdentifier))"
    }

}
