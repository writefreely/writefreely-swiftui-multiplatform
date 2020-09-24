import Foundation

private struct InfoPlistConstants {
    static let versionNumber = "CFBundleShortVersionString"
    static let buildNumber = "CFBundleVersion"
}

extension Bundle {
    public var appMarketingVersion: String {
        guard let result = infoDictionary?[InfoPlistConstants.versionNumber] as? String else {
            return "⚠️"
        }
        return result
    }

    public var appBuildVersion: String {
        guard let result = infoDictionary?[InfoPlistConstants.buildNumber] as? String else {
            return "⚠️"
        }
        return result
    }
}
