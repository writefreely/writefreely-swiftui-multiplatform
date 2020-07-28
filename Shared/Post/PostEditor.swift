//
//  PostEditor.swift
//  WriteFreely-MultiPlatform
//
//  Created by Angelo Stavrow on 2020-07-24.
//

import SwiftUI

struct PostEditor: View {
    @State var post: Post
    @State private var hasUnpublishedChanges: Bool = false

    var body: some View {
        VStack {
            TextField(post.title, text: $post.title)
                .font(.title)
                .multilineTextAlignment(.center)
                .padding(.bottom)
                .onChange(of: post.title) { _ in
                    if post.status == .published {
                        hasUnpublishedChanges = true
                    }
                }
            TextEditor(text: $post.body)
                .font(.body)
                .padding(.leading)
                .onChange(of: post.body) { _ in
                    if post.status == .published {
                        hasUnpublishedChanges = true
                    }
                }
                .toolbar {
                    if hasUnpublishedChanges {
                        PostStatusBadge(postStatus: .edited)
                    } else {
                        PostStatusBadge(postStatus: post.status)
                    }
                }
        }
    }
}

struct PostEditor_Previews: PreviewProvider {
    static var previews: some View {
        PostEditor(post: testPost)
    }
}
