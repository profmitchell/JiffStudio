import SwiftUI

struct PreviewView: View {
    @ObservedObject var viewModel: ContentViewModel
    
    var body: some View {
        VStack {
            if let previewImage = viewModel.previewImage {
                Image(nsImage: previewImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
            } else {
                Text("GIF Preview Will Appear Here")
                    .frame(height: 300)
            }
        }
        .background(Color.black.opacity(0.1))
        .cornerRadius(10)
        .padding()
    }
}