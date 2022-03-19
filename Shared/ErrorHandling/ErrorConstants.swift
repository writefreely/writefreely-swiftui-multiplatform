import Foundation

// MARK: - Network Errors

enum NetworkError: Error {
    case noConnectionError
}

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .noConnectionError:
            return NSLocalizedString(
                "There is no internet connection at the moment. Please reconnect or try again later.",
                comment: ""
            )
        }
    }
}

// MARK: - Keychain Errors

enum KeychainError: Error {
    case couldNotStoreAccessToken
    case couldNotPurgeAccessToken
}

extension KeychainError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .couldNotStoreAccessToken:
            return NSLocalizedString("There was a problem storing your access token in the Keychain.", comment: "")
        case .couldNotPurgeAccessToken:
            return NSLocalizedString("Something went wrong purging the token from the Keychain.", comment: "")
        }
    }
}

// MARK: - Account Errors

enum AccountError: Error {
    case invalidPassword
    case usernameNotFound
    case serverNotFound
    case invalidServerURL
    case couldNotSaveTokenToKeychain
    case couldNotFetchTokenFromKeychain
    case couldNotDeleteTokenFromKeychain
    case unknownLoginError
    case genericAuthError
}

extension AccountError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .serverNotFound:
            return NSLocalizedString(
                "The server could not be found. Please check the information you've entered and try again.",
                comment: ""
            )
        case .invalidPassword:
            return NSLocalizedString(
                "Invalid password. Please check that you've entered your password correctly and try logging in again.",
                comment: ""
            )
        case .usernameNotFound:
            return NSLocalizedString(
                "Username not found. Did you use your email address by mistake?",
                comment: ""
            )
        case .invalidServerURL:
            return NSLocalizedString(
                "Please enter a valid instance domain name. It should look like \"https://example.com\" or \"write.as\".",  // swiftlint:disable:this line_length
                comment: ""
            )
        case .couldNotSaveTokenToKeychain:
            return NSLocalizedString(
                "There was a problem trying to save your access token to the device, please try logging in again.",
                comment: ""
            )
        case .couldNotFetchTokenFromKeychain:
            return NSLocalizedString(
                "There was a problem trying to fetch your access token from the device, please try logging in again.",
                comment: ""
            )
        case .couldNotDeleteTokenFromKeychain:
            return NSLocalizedString(
                "There was a problem trying to delete your access token from the device, please try logging out again.",
                comment: ""
            )
        case .genericAuthError:
            return NSLocalizedString("Something went wrong, please try logging in again.", comment: "")
        case .unknownLoginError:
            return NSLocalizedString("An unknown error occurred while trying to login.", comment: "")
        }
    }
}

// MARK: - Local Store Errors

enum LocalStoreError: Error {
    case couldNotSaveContext
    case couldNotFetchCollections
    case couldNotFetchPosts(String)
    case couldNotPurgePublishedPosts
    case couldNotPurgeCollections
    case couldNotLoadStore(String)
    case couldNotMigrateStore(String)
    case couldNotDeleteStoreAfterMigration(String)
    case genericError(String)
}

extension LocalStoreError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .couldNotSaveContext:
            return NSLocalizedString("Error saving context", comment: "")
        case .couldNotFetchCollections:
            return NSLocalizedString("Failed to fetch blogs from local store.", comment: "")
        case .couldNotFetchPosts(let postFilter):
            if postFilter.isEmpty {
                return NSLocalizedString("Failed to fetch posts from local store.", comment: "")
            } else {
                return NSLocalizedString("Failed to fetch \(postFilter) posts from local store.", comment: "")
            }
        case .couldNotPurgePublishedPosts:
            return NSLocalizedString("Failed to purge published posts from local store.", comment: "")
        case .couldNotPurgeCollections:
            return NSLocalizedString("Failed to purge cached collections", comment: "")
        case .couldNotLoadStore(let errorDescription):
            return NSLocalizedString("Something went wrong loading local store: \(errorDescription)", comment: "")
        case .couldNotMigrateStore(let errorDescription):
            return NSLocalizedString("Something went wrong migrating local store: \(errorDescription)", comment: "")
        case .couldNotDeleteStoreAfterMigration(let errorDescription):
            return NSLocalizedString("Something went wrong deleting old store: \(errorDescription)", comment: "")
        case .genericError(let customContent):
            if customContent.isEmpty {
                return NSLocalizedString("Something went wrong accessing device storage", comment: "")
            } else {
                return NSLocalizedString(customContent, comment: "")
            }
        }
    }
}

// MARK: - Application Errors

enum AppError: Error {
    case couldNotGetLoggedInClient
    case couldNotGetPostId
}

extension AppError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .couldNotGetLoggedInClient:
            return NSLocalizedString("Something went wrong trying to access the WriteFreely client.", comment: "")
        case .couldNotGetPostId:
            return NSLocalizedString("Something went wrong trying to get the post's unique ID.", comment: "")
        }
    }
}

// MARK: - Fetch Errors
