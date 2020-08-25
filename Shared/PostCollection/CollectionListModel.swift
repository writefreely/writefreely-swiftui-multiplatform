import SwiftUI

class CollectionListModel: ObservableObject {
    private(set) var userCollections: [PostCollection] = []
    @Published private(set) var collectionsList: [PostCollection] = [ allPostsCollection, draftsCollection ]

    init(with userCollections: [PostCollection]) {
        for userCollection in userCollections {
            self.userCollections.append(userCollection)
        }
        collectionsList.append(contentsOf: self.userCollections)
    }

    func clearUserCollection() {
        userCollections = []
        collectionsList = [ allPostsCollection, draftsCollection ]
    }
}
