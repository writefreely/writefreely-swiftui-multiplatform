import SwiftUI
import CoreData

enum PostAppearance: String {
    case sans = "OpenSans-Regular"
    case mono = "Hack-Regular"
    case serif = "Lora-Regular"
}

struct PostEditorModel {
    @AppStorage(WFDefaults.showAllPostsFlag, store: UserDefaults.shared) var showAllPostsFlag: Bool = false
    @AppStorage(WFDefaults.selectedCollectionURL, store: UserDefaults.shared) var selectedCollectionURL: URL?
    @AppStorage(WFDefaults.lastDraftURL, store: UserDefaults.shared) var lastDraftURL: URL?

    #if os(macOS)
    var postToUpdate: WFAPost?
    #endif

    func saveLastDraft(_ post: WFAPost) {
        self.lastDraftURL = post.status != PostStatus.published.rawValue ? post.objectID.uriRepresentation() : nil
    }

    func clearLastDraft() {
        self.lastDraftURL = nil
    }

    func fetchLastDraftFromAppStorage() -> WFAPost? {
        guard let postURL = lastDraftURL else { return nil }
        guard let post = fetchManagedObject(from: postURL) as? WFAPost else { return nil }
        return post
    }

    func generateNewLocalPost(withFont appearance: Int) -> WFAPost {
        let managedPost = WFAPost(context: LocalStorageManager.standard.container.viewContext)
        managedPost.createdDate = Date()
        managedPost.title = ""
        managedPost.body = ""
        managedPost.status = PostStatus.local.rawValue
        managedPost.collectionAlias = WriteFreelyModel.shared.selectedCollection?.alias
        switch appearance {
        case 1:
            managedPost.appearance = "sans"
        case 2:
            managedPost.appearance = "wrap"
        default:
            managedPost.appearance = "serif"
        }
        if let languageCode = Locale.current.languageCode {
            managedPost.language = languageCode
            managedPost.rtl = Locale.characterDirection(forLanguage: languageCode) == .rightToLeft
        }
        return managedPost
    }

    func fetchSelectedCollectionFromAppStorage() -> WFACollection? {
        guard let collectionURL = selectedCollectionURL else { return nil }
        guard let collection = fetchManagedObject(from: collectionURL) as? WFACollection else { return nil }
        return collection
    }

    private func fetchManagedObject(from objectURL: URL) -> NSManagedObject? {
        let coordinator = LocalStorageManager.standard.container.persistentStoreCoordinator
        guard let managedObjectID = coordinator.managedObjectID(forURIRepresentation: objectURL) else { return nil }
        let object = LocalStorageManager.standard.container.viewContext.object(with: managedObjectID)
        return object
    }
}
