import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    
    var body: some View {
        VStack {
            HStack {
                Button("Import PNG Sequence") {
                    viewModel.importPNGSequence()
                }
                Button("Import Video") {
                    viewModel.importVideo()
                }
            }
            .padding()
            
            ParametersView(viewModel: viewModel)
            
            PreviewView(viewModel: viewModel)
            
            HStack {
                Button("Render Preview") {
                    viewModel.renderPreview()
                }
                Button("Export GIF") {
                    viewModel.exportGIF()
                }
            }
            .padding()
        }
        .frame(minWidth: 600, minHeight: 400)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}