//
//  PostEditor.swift
//  WriteFreely-MultiPlatform
//
//  Created by Angelo Stavrow on 2020-07-24.
//

import SwiftUI

struct PostEditor: View {
    @State var textString: String = ""
    @State private var hasUnpublishedChanges: Bool = false
    var postStatus: PostStatus = .draft

    var body: some View {
        TextEditor(text: $textString.animation())
            .font(.body)
            .padding()
            .onChange(of: textString) { _ in
                if postStatus == .published {
                    hasUnpublishedChanges = true
                }
            }
            .toolbar {
                if hasUnpublishedChanges {
                    PostStatusBadge(postStatus: .edited)
                } else {
                    PostStatusBadge(postStatus: postStatus)
                }
            }
    }
}

struct PostEditor_Previews: PreviewProvider {
    static var previews: some View {
        PostEditor(
            textString: testPost.editableText,
            postStatus: testPost.status
        )
    }
}
