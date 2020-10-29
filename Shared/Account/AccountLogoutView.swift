import SwiftUI

struct AccountLogoutView: View {
    @EnvironmentObject var model: WriteFreelyModel

    @State private var isPresentingLogoutConfirmation: Bool = false
    @State private var editedPostsWarningString: String = ""

    var body: some View {
        VStack {
            Spacer()
            VStack {
                Text("Logged in as \(model.account.username)")
                Text("on \(model.account.server)")
            }
            Spacer()
            Button(action: logoutHandler, label: {
                Text("Log Out")
            })
        }
        .actionSheet(isPresented: $isPresentingLogoutConfirmation, content: {
            ActionSheet(
                title: Text("Log Out?"),
                message: Text("\(editedPostsWarningString)You won't lose any local posts. Are you sure?"),
                buttons: [
                    .destructive(Text("Log Out"), action: {
                        model.logout()
                    }),
                    .cancel()
                ]
            )
        })
    }

    func logoutHandler() {
        let request = WFAPost.createFetchRequest()
        request.predicate = NSPredicate(format: "status == %i", 1)
        do {
            let editedPosts = try LocalStorageManager.persistentContainer.viewContext.fetch(request)
            if editedPosts.count == 1 {
                editedPostsWarningString = "You'll lose unpublished changes to \(editedPosts.count) edited post. "
            }
            if editedPosts.count > 1 {
                editedPostsWarningString = "You'll lose unpublished changes to \(editedPosts.count) edited posts. "
            }
        } catch {
            print("Error: failed to fetch cached posts")
        }
        self.isPresentingLogoutConfirmation = true
    }
}

struct AccountLogoutView_Previews: PreviewProvider {
    static var previews: some View {
        AccountLogoutView()
            .environmentObject(WriteFreelyModel())
    }
}
