import SwiftUI
import CoreData

class PostListModel: ObservableObject {
    func remove(_ post: WFAPost) {
        withAnimation {
            LocalStorageManager.standard.persistentContainer.viewContext.delete(post)
            LocalStorageManager.standard.saveContext()
        }
    }

    func purgePublishedPosts() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "WFAPost")
        fetchRequest.predicate = NSPredicate(format: "status != %i", 0)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try LocalStorageManager.standard.persistentContainer.viewContext.executeAndMergeChanges(using: deleteRequest)
        } catch {
            print("Error: Failed to purge cached posts.")
        }
    }

    func getBodyPreview(of post: WFAPost) -> String {
        var elidedPostBody: String = ""

        // Strip any markdown from the post body.
        let strippedPostBody = stripMarkdown(from: post.body)

        // Extract lede from post.
         elidedPostBody = extractLede(from: strippedPostBody)

        return elidedPostBody
    }
}

private extension PostListModel {

    func stripMarkdown(from string: String) -> String {
        var strippedString = string
        strippedString = stripHeadingOctothorpes(from: strippedString)
        strippedString = stripImages(from: strippedString, keepAltText: true)
        return strippedString
    }

    func stripHeadingOctothorpes(from string: String) -> String {
        let newLines = CharacterSet.newlines
        var processedComponents: [String] = []
        let components = string.components(separatedBy: newLines)
        for component in components {
            if component.isEmpty {
                continue
            }
            var newString = component
            while newString.first == "#" {
                newString.removeFirst()
            }
            if newString.hasPrefix(" ") {
                newString.removeFirst()
            }
            processedComponents.append(newString)
        }
        let headinglessString = processedComponents.joined(separator: "\n\n")
        return headinglessString
    }

    func stripImages(from string: String, keepAltText: Bool = false) -> String {
        let pattern = #"!\[[\"]?(.*?)[\"|]?\]\(.*?\)"#
        var processedComponents: [String] = []
        let components = string.components(separatedBy: .newlines)
        for component in components {
            if component.isEmpty { continue }
            var processedString: String = component
            if keepAltText {
                let regex = try? NSRegularExpression(pattern: pattern, options: [])
                if let matches = regex?.matches(
                    in: component, options: [], range: NSRange(location: 0, length: component.utf16.count)
                ) {
                    for match in matches {
                        if let range = Range(match.range(at: 1), in: component) {
                            processedString = "\(component[range])"
                        }
                    }
                }
            } else {
                let range = component.startIndex..<component.endIndex
                processedString = component.replacingOccurrences(
                    of: pattern,
                    with: "",
                    options: .regularExpression,
                    range: range
                )
            }
            if processedString.isEmpty { continue }
            processedComponents.append(processedString)
        }
        return processedComponents.joined(separator: "\n\n")
    }

    func extractLede(from string: String) -> String {
        let truncatedString = string.prefix(80)
        let terminatingPunctuation = ".。?"
        let terminatingCharacters = CharacterSet(charactersIn: terminatingPunctuation).union(.newlines)

        var lede: String = ""
        let sentences = truncatedString.components(separatedBy: terminatingCharacters)
        if let firstSentence = (sentences.filter { !$0.isEmpty }).first {
            if truncatedString.count > firstSentence.count {
                if terminatingPunctuation.contains(truncatedString[firstSentence.endIndex]) {
                    lede = String(truncatedString[...firstSentence.endIndex])
                } else {
                    lede = firstSentence
                }
            } else if truncatedString.count == firstSentence.count {
                if string.count > 80 {
                    if let endOfStringIndex = truncatedString.lastIndex(of: " ") {
                        lede = truncatedString[..<endOfStringIndex] + "…"
                    }
                } else {
                    lede = firstSentence
                }
            }
        }
        return lede
    }
}
