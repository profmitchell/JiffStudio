import SwiftUI

struct ParametersView: View {
    @ObservedObject var viewModel: ContentViewModel
    
    var body: some View {
        VStack {
            HStack {
                Text("Frame Rate: \(Int(viewModel.frameRate)) fps")
                Slider(value: $viewModel.frameRate, in: 10...60, step: 1)
            }
            HStack {
                Text("Resolution:")
                Picker("Resolution", selection: $viewModel.resolution) {
                    Text("480p").tag("480p")
                    Text("720p").tag("720p")
                    Text("1080p").tag("1080p")
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            HStack {
                Text("Color Palette: \(viewModel.colorPalette)")
                Slider(value: Binding(
                    get: { Double(viewModel.colorPalette) },
                    set: { viewModel.colorPalette = Int($0) }
                ), in: 64...256, step: 1)
            }
            Toggle("Infinite Looping", isOn: $viewModel.isLooping)
        }
        .padding()
    }
}