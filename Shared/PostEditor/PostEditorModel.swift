import SwiftUI
import CoreData

enum PostAppearance: String {
    case sans = "OpenSans-Regular"
    case mono = "Hack-Regular"
    case serif = "Lora-Regular"
}

struct PostEditorModel {
    @AppStorage("showAllPostsFlag") var showAllPostsFlag: Bool = false
    @AppStorage("selectedCollectionURL") var selectedCollectionURL: URL?
    @AppStorage("selectedPostURL") var selectedPostURL: URL?
    @AppStorage("lastDraftURL") private var lastDraftURL: URL?

    func saveLastDraft(_ post: WFAPost) {
        self.lastDraftURL = post.status != PostStatus.published.rawValue ? post.objectID.uriRepresentation() : nil
    }

    func clearLastDraft() {
        self.lastDraftURL = nil
    }

    func fetchLastDraftFromUserDefaults() -> WFAPost? {
        guard let postURL = lastDraftURL else { return nil }

        let coordinator = LocalStorageManager.persistentContainer.persistentStoreCoordinator
        guard let postManagedObjectID = coordinator.managedObjectID(forURIRepresentation: postURL) else { return nil }
        guard let post = LocalStorageManager.persistentContainer.viewContext.object(
            with: postManagedObjectID
        ) as? WFAPost else { return nil }

        return post
    }

    func generateNewLocalPost(withFont appearance: Int) -> WFAPost {
        let managedPost = WFAPost(context: LocalStorageManager.persistentContainer.viewContext)
        managedPost.createdDate = Date()
        managedPost.title = ""
        managedPost.body = ""
        managedPost.status = PostStatus.local.rawValue
        managedPost.collectionAlias = nil
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

    private func fetchManagedObject(from objectURL: URL) -> NSManagedObject? {
        let coordinator = LocalStorageManager.persistentContainer.persistentStoreCoordinator
        guard let managedObjectID = coordinator.managedObjectID(forURIRepresentation: objectURL) else { return nil }
        let object = LocalStorageManager.persistentContainer.viewContext.object(with: managedObjectID)
        return object
    }

    func fetchSelectedPostFromAppStorage() -> WFAPost? {
        guard let postURL = selectedPostURL else { return nil }
        guard let post = fetchManagedObject(from: postURL) as? WFAPost else { return nil }
        return post
    }

    func fetchSelectedCollectionFromAppStorage() -> WFACollection? {
        guard let collectionURL = selectedCollectionURL else { return nil }
        guard let collection = fetchManagedObject(from: collectionURL) as? WFACollection else { return nil }
        return collection
    }
}
