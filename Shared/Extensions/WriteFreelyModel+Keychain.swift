import Foundation

extension WriteFreelyModel {

    enum WFKeychainError: Error {
        case saveToKeychainFailed
        case purgeFromKeychainFailed
        case fetchFromKeychainFailed
    }

    func saveTokenToKeychain(_ token: String, username: String?, server: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecValueData as String: token.data(using: .utf8)!,
            kSecAttrAccount as String: username ?? "anonymous",
            kSecAttrService as String: server
        ]
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecDuplicateItem || status == errSecSuccess else {
            throw WFKeychainError.saveToKeychainFailed
        }
    }

    func purgeTokenFromKeychain(username: String?, server: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: username ?? "anonymous",
            kSecAttrService as String: server
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw WFKeychainError.purgeFromKeychainFailed
        }
    }

    func fetchTokenFromKeychain(username: String?, server: String) throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: username ?? "anonymous",
            kSecAttrService as String: server,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true
        ]
        var secItem: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &secItem)
        guard status != errSecItemNotFound else {
            return nil
        }
        guard status == errSecSuccess else {
            throw WFKeychainError.fetchFromKeychainFailed
        }
        guard let existingSecItem = secItem as? [String: Any],
              let tokenData = existingSecItem[kSecValueData as String] as? Data,
              let token = String(data: tokenData, encoding: .utf8) else {
            return nil
        }
        return token
    }

}
