import SwiftUI

struct PostCommands: Commands {
    @State var post: WFAPost?

    var body: some Commands {
        CommandMenu("Post") {
            Button("Publish…") {
                print("Published active post (not really): '\(post?.title ?? "untitled")'")
            }
            Button("Move…") {
                print("Moved active post (not really): '\(post?.title ?? "untitled")'")
            }
            Button("Copy Link To Post") {
                print("Copied URL to post (not really): '\(post?.title ?? "untitled")'")
            }
        }
    }
}
