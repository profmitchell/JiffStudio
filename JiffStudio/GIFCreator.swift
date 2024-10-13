import Foundation
import ImageIO
import UniformTypeIdentifiers
import AppKit

class GIFCreator {
    static func createGIF(from images: [NSImage], frameRate: Double, loopCount: Int, colorPalette: Int, outputURL: URL) throws {
        guard let destination = CGImageDestinationCreateWithURL(outputURL as CFURL, UTType.gif.identifier as CFString, images.count, nil) else {
            throw GIFError.destinationCreationFailed
        }
        
        let frameProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFDelayTime as String: 1.0 / frameRate]]
        let gifProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFLoopCount as String: loopCount]]
        
        CGImageDestinationSetProperties(destination, gifProperties as CFDictionary)
        
        for image in images {
            if let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) {
                CGImageDestinationAddImage(destination, cgImage, frameProperties as CFDictionary)
            }
        }
        
        if !CGImageDestinationFinalize(destination) {
            throw GIFError.finalizationFailed
        }
    }
}

enum GIFError: Error {
    case destinationCreationFailed
    case finalizationFailed
}