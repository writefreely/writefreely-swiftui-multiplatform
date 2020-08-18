import Foundation

// MARK: - WriteFreelyModel

class WriteFreelyModel: ObservableObject {
    @Published var account = AccountModel()
    @Published var preferences = PreferencesModel()
    @Published var store = PostStore()
    @Published var post: Post?

    init() {
        #if DEBUG
        for post in testPostData { store.add(post) }
        #endif
    }
}

// MARK: - WriteFreelyModel API

extension WriteFreelyModel {
    // API goes here
}
