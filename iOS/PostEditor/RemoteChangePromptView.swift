import SwiftUI

enum RemotePostChangeType {
    case remoteCopyUpdated
    case remoteCopyDeleted
}

struct RemoteChangePromptView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var promptText: String = "This is placeholder prompt text. Replace it?"
    @State private var promptIcon: Image = Image(systemName: "questionmark.square.dashed")
    @State var remoteChangeType: RemotePostChangeType
    @State var buttonHandler: () -> Void

    var body: some View {
        HStack {
            Text("⚠️ \(promptText)")
                .font(horizontalSizeClass == .compact ? .caption : .body)
                .foregroundColor(.secondary)
            Button(action: buttonHandler, label: { promptIcon })
        }
        .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(Capsule())
        .padding(.bottom)
        .onAppear(perform: {
            switch remoteChangeType {
            case .remoteCopyUpdated:
                promptText = "Newer copy on server. Replace local copy?"
                promptIcon = Image(systemName: "square.and.arrow.down")
            case .remoteCopyDeleted:
                promptText = "Post deleted from server. Delete local copy?"
                promptIcon = Image(systemName: "trash")
            }
        })
    }
}

struct RemoteChangePromptView_UpdatedPreviews: PreviewProvider {
    static var previews: some View {
        RemoteChangePromptView(
            remoteChangeType: .remoteCopyUpdated,
            buttonHandler: { print("Hello, updated post!") }
        )
    }
}

struct RemoteChangePromptView_DeletedPreviews: PreviewProvider {
    static var previews: some View {
        RemoteChangePromptView(
            remoteChangeType: .remoteCopyDeleted,
            buttonHandler: { print("Goodbye, deleted post!") }
        )
    }
}
