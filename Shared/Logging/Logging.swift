//
//  Logging.swift
//  WriteFreely-MultiPlatform
//
//  Created by Angelo Stavrow on 2022-06-25.
//

import Foundation
import os
import OSLog

protocol LogWriter {
    func log(_ message: String, withSensitiveInfo privateInfo: String?, level: OSLogType)
    func logCrashAndSetFlag(error: Error)
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
