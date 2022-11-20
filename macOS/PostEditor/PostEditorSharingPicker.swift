import SwiftUI

struct PostEditorSharingPicker: NSViewRepresentable {
    @Binding var isPresented: Bool
    var sharingItems: [Any] = []

    func makeNSView(context: Context) -> some NSView {
        let view = NSView()
        return view
    }

    func updateNSView(_ nsView: NSViewType, context: Context) {
        if isPresented {
            let picker = NSSharingServicePicker(items: sharingItems)
            picker.delegate = context.coordinator

            DispatchQueue.main.async {
                picker.show(relativeTo: .zero, of: nsView, preferredEdge: .minY)
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(owner: self)
    }

    class Coordinator: NSObject, NSSharingServicePickerDelegate {
        let owner: PostEditorSharingPicker

        init(owner: PostEditorSharingPicker) {
            self.owner = owner
        }

        func sharingServicePicker(
            _ sharingServicePicker: NSSharingServicePicker,
            didChoose service: NSSharingService?
        ) {
            sharingServicePicker.delegate = nil
            self.owner.isPresented = false
        }
    }
}
