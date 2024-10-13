import SwiftUI
import AVFoundation
import UniformTypeIdentifiers

@MainActor
class ContentViewModel: ObservableObject {
    @Published var importedImages: [Image] = []
    @Published var importedVideoURL: URL?
    @Published var frameRate: Double = 15.0
    @Published var resolution: String = "720p"
    @Published var colorPalette: Int = 128
    @Published var isLooping: Bool = true
    @Published var gifPreviewURL: URL?
    
    func importPNGSequence() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.canCreateDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [UTType.png]
        
        if panel.runModal() == .OK {
            importedImages = panel.urls.compactMap { Image(nsImage: NSImage(contentsOf: $0)!) }
            importedVideoURL = nil
            renderPreview()
        }
    }
    
    func importVideo() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canCreateDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [UTType.movie]
        
        if panel.runModal() == .OK {
            importedVideoURL = panel.url
            importedImages = []
            extractVideoFrames()
        }
    }
    
    func renderPreview() {
        Task {
            do {
                let previewURL = FileManager.default.temporaryDirectory.appendingPathComponent("preview.gif")
                try GIFCreator.createGIF(from: importedImages, frameRate: frameRate, loopCount: isLooping ? 0 : 1, colorPalette: colorPalette, outputURL: previewURL)
                await MainActor.run {
                    self.gifPreviewURL = previewURL
                }
            } catch {
                print("Error rendering preview: \(error)")
            }
        }
    }
    
    func exportGIF() {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [UTType.gif]
        savePanel.canCreateDirectories = true
        savePanel.nameFieldStringValue = "exported.gif"
        
        if savePanel.runModal() == .OK {
            guard let url = savePanel.url else { return }
            
            Task {
                do {
                    try GIFCreator.createGIF(from: importedImages, frameRate: frameRate, loopCount: isLooping ? 0 : 1, colorPalette: colorPalette, outputURL: url)
                    print("GIF exported successfully")
                } catch {
                    print("Error exporting GIF: \(error)")
                }
            }
        }
    }
    
    private func extractVideoFrames() {
        guard let videoURL = importedVideoURL else { return }
        
        let asset = AVAsset(url: videoURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        Task {
            do {
                let duration = try await asset.load(.duration)
                let frameCount = Int(duration.seconds * frameRate)
                
                let times = stride(from: 0.0, to: duration.seconds, by: 1.0 / frameRate).map {
                    NSValue(time: CMTime(seconds: $0, preferredTimescale: 600))
                }
                
                for time in times {
                    let cgImage = try await imageGenerator.image(at: time.timeValue).image
                    let nsImage = NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
                    let image = Image(nsImage: nsImage)
                    await MainActor.run {
                        self.importedImages.append(image)
                        if self.importedImages.count == frameCount {
                            self.renderPreview()
                        }
                    }
                }
            } catch {
                print("Error extracting video frames: \(error)")
            }
        }
    }
}