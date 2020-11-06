import SwiftUI
import CoreData

enum PostAppearance: String {
    case sans = "OpenSans-Regular"
    case mono = "Hack-Regular"
    case serif = "Lora-Regular"
}

struct PostEditorModel {
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
}
