import SwiftUI

struct CollectionPicker: View {
    @Binding var selectedCollection: PostCollection

    private let collections = [
        allPostsCollection,
        defaultDraftCollection,
        testPostCollection1,
        testPostCollection2,
        testPostCollection3
    ]

    var body: some View {
        Picker("Collection", selection: $selectedCollection) {
            ForEach(collections) { collection in
                Text(collection.title).tag(collection)
            }
        }
    }
}
