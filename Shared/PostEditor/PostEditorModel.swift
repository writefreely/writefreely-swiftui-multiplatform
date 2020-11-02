import Foundation
import CoreData

enum PostAppearance: String {
    case sans = "OpenSans-Regular"
    case mono = "Hack-Regular"
    case serif = "Lora-Regular"
}

struct PostEditorModel {
    let lastDraftObjectURLKey = "lastDraftObjectURLKey"
    private(set) var lastDraft: WFAPost?

    mutating func setLastDraft(_ post: WFAPost) {
        lastDraft = post
        UserDefaults.standard.set(post.objectID.uriRepresentation(), forKey: lastDraftObjectURLKey)
    }

    mutating func fetchLastDraft() -> WFAPost? {
        let coordinator = LocalStorageManager.persistentContainer.persistentStoreCoordinator

        // See if we have a lastDraftObjectURI
        guard let lastDraftObjectURI = UserDefaults.standard.url(forKey: lastDraftObjectURLKey) else { return nil }

        // See if we can get an ObjectID from the URI representation
        guard let lastDraftObjectID = coordinator.managedObjectID(forURIRepresentation: lastDraftObjectURI) else {
            return nil
        }

        lastDraft = LocalStorageManager.persistentContainer.viewContext.object(with: lastDraftObjectID) as? WFAPost
        return lastDraft
    }

    mutating func clearLastDraft() {
        lastDraft = nil
        UserDefaults.standard.removeObject(forKey: lastDraftObjectURLKey)
    }
}
