import Foundation

enum WFDefaults {
    static let isLoggedIn = "isLoggedIn"
    static let showAllPostsFlag = "showAllPostsFlag"
    static let selectedCollectionURL = "selectedCollectionURL"
    static let lastDraftURL = "lastDraftURL"
    static let colorSchemeIntegerKey = "colorSchemeIntegerKey"
    static let defaultFontIntegerKey = "defaultFontIntegerKey"
    static let usernameStringKey = "usernameStringKey"
    static let serverStringKey = "serverStringKey"
    #if os(macOS)
    static let automaticallyChecksForUpdates = "automaticallyChecksForUpdates"
    static let subscribeToBetaUpdates = "subscribeToBetaUpdates"
    #endif
}

extension UserDefaults {

    private enum DefaultsError: Error {
        case couldNotMigrateStandardDefaults

        var description: String {
            switch self {
            case .couldNotMigrateStandardDefaults:
                return "Could not migrate user defaults to group container."
            }
        }
    }

    private static let appGroupName: String = "group.com.abunchtell.writefreely"
    private static let didMigrateDefaultsToAppGroup: String = "didMigrateDefaultsToAppGroup"
    private static let didRemoveStandardDefaults: String = "didRemoveStandardDefaults"

    static var shared: UserDefaults {
        if let groupDefaults = UserDefaults(suiteName: UserDefaults.appGroupName),
           groupDefaults.bool(forKey: UserDefaults.didMigrateDefaultsToAppGroup) {
            return groupDefaults
        } else {
            do {
                let groupDefaults = try UserDefaults.standard.migrateDefaultsToAppGroup()
                return groupDefaults
            } catch {
                return UserDefaults.standard
            }
        }
    }

    private func migrateDefaultsToAppGroup() throws -> UserDefaults {
        let userDefaults = UserDefaults.standard
        let groupDefaults = UserDefaults(suiteName: UserDefaults.appGroupName)

        if let groupDefaults = groupDefaults {
            if groupDefaults.bool(forKey: UserDefaults.didMigrateDefaultsToAppGroup) {
                return groupDefaults
            }

            for (key, value) in userDefaults.dictionaryRepresentation() {
                groupDefaults.set(value, forKey: key)
            }
            groupDefaults.set(true, forKey: UserDefaults.didMigrateDefaultsToAppGroup)
            return groupDefaults
        } else {
            throw DefaultsError.couldNotMigrateStandardDefaults
        }
    }

}
