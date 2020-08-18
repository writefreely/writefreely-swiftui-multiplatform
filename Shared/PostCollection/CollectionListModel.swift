import SwiftUI

struct CollectionListModel {
    private(set) var userCollections: [PostCollection] = []
    private(set) var collectionsList: [PostCollection]

    init() {
        collectionsList = [ allPostsCollection, draftsCollection ]

        #if DEBUG
        userCollections = [ userCollection1, userCollection2, userCollection3 ]
        #endif

        for userCollection in userCollections {
            collectionsList.append(userCollection)
        }
    }
}
