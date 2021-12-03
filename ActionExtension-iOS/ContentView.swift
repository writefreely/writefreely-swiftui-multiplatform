import SwiftUI
import MobileCoreServices
import UniformTypeIdentifiers
import WriteFreely

enum WFActionExtensionError: Error {
    case userCancelledRequest
    case couldNotParseInputItems
}

struct ContentView: View {
    @Environment(\.extensionContext) private var extensionContext: NSExtensionContext!
    @Environment(\.managedObjectContext) private var managedObjectContext

    @AppStorage(WFDefaults.defaultFontIntegerKey, store: UserDefaults.shared) var fontIndex: Int = 0

    @FetchRequest(
        entity: WFACollection.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \WFACollection.title, ascending: true)]
    ) var collections: FetchedResults<WFACollection>

    @State private var draftTitle: String = ""
    @State private var draftText: String = ""
    @State private var isShowingAlert: Bool = false
    @State private var selectedBlog: WFACollection?

    private var draftsCollectionName: String {
        guard UserDefaults.shared.string(forKey: WFDefaults.serverStringKey) == "https://write.as" else {
            return "Drafts"
        }
        return "Anonymous"
    }

    private var controls: some View {
            HStack {
                Group {
                Button(
                    action: { extensionContext.cancelRequest(withError: WFActionExtensionError.userCancelledRequest) },
                    label: { Image(systemName: "xmark.circle").imageScale(.large) }
                )
                .accessibilityLabel(Text("Cancel"))
                Spacer()
                Button(
                    action: {
                        savePostToCollection(collection: selectedBlog, title: draftTitle, body: draftText)
                        extensionContext.completeRequest(returningItems: nil, completionHandler: nil)
                    },
                    label: { Image(systemName: "square.and.arrow.down").imageScale(.large) }
                )
                .accessibilityLabel(Text("Create new draft"))
                }
                .padding()
            }
    }

    var body: some View {
        VStack {
            controls
            Form {
                Section(header: Text("Title")) {
                    switch fontIndex {
                    case 1:
                        TextField("Draft Title", text: $draftTitle).font(.custom("OpenSans-Regular", size: 26))
                    case 2:
                        TextField("Draft Title", text: $draftTitle).font(.custom("Hack-Regular", size: 26))
                    default:
                        TextField("Draft Title", text: $draftTitle).font(.custom("Lora", size: 26))
                    }
                }
                Section(header: Text("Content")) {
                    switch fontIndex {
                    case 1:
                        TextEditor(text: $draftText).font(.custom("OpenSans-Regular", size: 17))
                    case 2:
                        TextEditor(text: $draftText).font(.custom("Hack-Regular", size: 17))
                    default:
                        TextEditor(text: $draftText).font(.custom("Lora", size: 17))
                    }
                }
                Section(header: Text("Save To")) {
                    Button(action: {
                        self.selectedBlog = nil
                    }, label: {
                        HStack {
                            Text(draftsCollectionName)
                                .foregroundColor(selectedBlog == nil ? .primary : .secondary)
                            Spacer()
                            if selectedBlog == nil {
                                Image(systemName: "checkmark")
                            }
                        }
                    })
                    ForEach(collections, id: \.self) { collection in
                        Button(action: {
                            self.selectedBlog = collection
                        }, label: {
                            HStack {
                                Text(collection.title)
                                    .foregroundColor(selectedBlog == collection ? .primary : .secondary)
                                Spacer()
                                if selectedBlog == collection {
                                    Image(systemName: "checkmark")
                                }
                            }
                        })
                    }
                }
            }
            .padding(.bottom, 24)
        }
        .alert(isPresented: $isShowingAlert, content: {
            Alert(
                title: Text("Something Went Wrong"),
                message: Text("WriteFreely can't create a draft with the data received."),
                dismissButton: .default(Text("OK"), action: {
                    extensionContext.cancelRequest(withError: WFActionExtensionError.couldNotParseInputItems)
                }))
        })
        .onAppear {
            do {
                try getPageDataFromExtensionContext()
            } catch {
                self.isShowingAlert = true
            }
        }
    }

    private func savePostToCollection(collection: WFACollection?, title: String, body: String) {
        let post = WFAPost(context: managedObjectContext)
        post.createdDate = Date()
        post.title = title
        post.body = body
        post.status = PostStatus.local.rawValue
        post.collectionAlias = collection?.alias
        switch fontIndex {
        case 1:
            post.appearance = "sans"
        case 2:
            post.appearance = "wrap"
        default:
            post.appearance = "serif"
        }
        if let languageCode = Locale.current.languageCode {
            post.language = languageCode
            post.rtl = Locale.characterDirection(forLanguage: languageCode) == .rightToLeft
        }
        LocalStorageManager.standard.saveContext()
    }

    private func getPageDataFromExtensionContext() throws {
        if let inputItem = extensionContext.inputItems.first as? NSExtensionItem {
            if let itemProvider = inputItem.attachments?.first {

                let typeIdentifier: String

                if #available(iOS 15, *) {
                    typeIdentifier = UTType.propertyList.identifier
                } else {
                    typeIdentifier = kUTTypePropertyList as String
                }

                itemProvider.loadItem(forTypeIdentifier: typeIdentifier) { (dict, error) in
                    if let error = error {
                        print("⚠️", error)
                        self.isShowingAlert = true
                    }

                    guard let itemDict = dict as? NSDictionary else {
                        return
                    }
                    guard let jsValues = itemDict[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary else {
                        return
                    }

                    let pageTitle = jsValues["title"] as? String ?? ""
                    let pageURL = jsValues["URL"] as? String ?? ""
                    let pageSelectedText = jsValues["selection"] as? String ?? ""

                    if pageSelectedText.isEmpty {
                        // If there's no selected text, create a Markdown link to the webpage.
                        self.draftText = "[\(pageTitle)](\(pageURL))"
                    } else {
                        // If there is selected text, create a Markdown blockquote with the selection
                        // and add a Markdown link to the webpage.
                        self.draftText = """
                        > \(pageSelectedText)

                        Via: [\(pageTitle)](\(pageURL))
                        """
                    }
                }
            } else {
                throw WFActionExtensionError.couldNotParseInputItems
            }
        } else {
            throw WFActionExtensionError.couldNotParseInputItems
        }
    }
}
