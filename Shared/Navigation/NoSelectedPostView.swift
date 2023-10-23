import SwiftUI

struct NoSelectedPostView: View {
    @Binding var isConnected: Bool

    var body: some View {
        VStack(spacing: 8) {
            Text("Select a post, or create a new local draft.")
            if !isConnected {
                Label("You are not connected to the internet", systemImage: "wifi.exclamationmark")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 500, height: 500)
    }
}

struct NoSelectedPostViewIsDisconnected_Previews: PreviewProvider {
    static var previews: some View {
        NoSelectedPostView(isConnected: Binding.constant(true))
    }
}

struct NoSelectedPostViewIsConnected_Previews: PreviewProvider {
    static var previews: some View {
        NoSelectedPostView(isConnected: Binding.constant(false))
    }
}
