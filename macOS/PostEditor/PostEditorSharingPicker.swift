import SwiftUI

struct PostEditorSharingPicker: NSViewRepresentable {
    @Binding var isPresented: Bool
    var sharingItems: [NSURL] = []

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
            sharingServicesForItems items: [Any],
            proposedSharingServices proposedServices: [NSSharingService]
        ) -> [NSSharingService] {
            guard let copyIcon = NSImage(systemSymbolName: "doc.on.doc", accessibilityDescription: "Copy URL") else {
                return proposedServices
            }

            var share = proposedServices
            let copyService = NSSharingService(
                title: "Copy URL",
                image: copyIcon,
                alternateImage: copyIcon,
                handler: {
                    if let url = items.first as? NSURL, let urlString = url.absoluteString {
                        let clipboard = NSPasteboard.general
                        clipboard.clearContents()
                        clipboard.setString(urlString, forType: .string)
                    }
                }
            )
            share.insert(copyService, at: 0)
            share.insert(NSSharingService(named: .addToSafariReadingList)!, at: 1)
            return share
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
