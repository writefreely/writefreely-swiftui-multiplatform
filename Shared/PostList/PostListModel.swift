import SwiftUI
import CoreData

class PostListModel: ObservableObject {
    func remove(_ post: WFAPost) {
        LocalStorageManager.persistentContainer.viewContext.delete(post)
        LocalStorageManager().saveContext()
    }

    func purgePublishedPosts() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "WFAPost")
        fetchRequest.predicate = NSPredicate(format: "status != %i", 0)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try LocalStorageManager.persistentContainer.viewContext.executeAndMergeChanges(using: deleteRequest)
        } catch {
            print("Error: Failed to purge cached posts.")
        }
    }

    func getBodyPreview(of post: WFAPost) -> String {
        var elidedPostBody: String = ""

        // Strip any markdown from the post body.
        let strippedPostBody = stripMarkdown(from: post.body)

        // Get the first 80 characters.
        let firstEightyChars = String(strippedPostBody.prefix(80))

        // Extract lede from post.
         elidedPostBody = extractLede(from: firstEightyChars)

        return elidedPostBody
    }
}

private extension PostListModel {

    func stripMarkdown(from string: String) -> String {
        return string
    }

    func extractLede(from string: String) -> String {
        let terminatingCharacters = CharacterSet(charactersIn: ".。?").union(.newlines)

        var lede: String

        let sentences = string.components(separatedBy: terminatingCharacters)
        let firstSentence = sentences.filter { !$0.isEmpty }[0]

        if firstSentence == string {
            let endOfStringIndex = string.lastIndex(of: " ")
            lede = String(string[..<(endOfStringIndex ?? string.index(string.endIndex, offsetBy: -2))]) + "…"
        } else {
            lede = firstSentence
        }

        return lede
    }
}
 
