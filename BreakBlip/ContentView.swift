//
//  ContentView.swift
//  BreakBlip
//
//  Created by EW on 24/06/2024.
//

import Cocoa
import SwiftUI
import AppKit

struct ContentView: View {
    @State private var isGrayscale = false
    @State private var clickCount = 0

    var body: some View {
        VStack {
            GIFImage(name: "PixelOfficer", isGrayscale: $isGrayscale)
                .frame(width: 128, height: 128)
                .onTapGesture(count: 2) {
                    Blip()
                }
            Spacer().frame(height: 20) // Add 20 points of white space between image and text
            Text("Burned-out \(clickCount) times")
                            .padding(.top, 10)
        }
        .frame(width: 128, height: 200) // Adjust the frame size to accommodate the text
    }

    func Blip() {
        // Increment click count
        clickCount += 1
        
        // Turn the gif gray
        isGrayscale = true
        
        // Color restored after 1 second
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isGrayscale = false
        }
    }
}

struct GIFImage: NSViewRepresentable {
    let name: String
    @Binding var isGrayscale: Bool

    func makeNSView(context: Context) -> NSImageView {
        let imageView = NSImageView()
        imageView.canDrawSubviewsIntoLayer = true
        updateImageView(imageView)
        imageView.imageScaling = .scaleProportionallyUpOrDown
        return imageView
    }

    func updateNSView(_ nsView: NSImageView, context: Context) {
        updateImageView(nsView)
    }

    private func updateImageView(_ imageView: NSImageView) {
        if let path = Bundle.main.path(forResource: name, ofType: "gif") {
            if let image = NSImage(contentsOfFile: path) {
                if isGrayscale {
                    imageView.image = image.grayscale
                } else {
                    imageView.image = image
                }
            }
        }
    }
}

extension NSImage {
    var grayscale: NSImage? {
        guard let tiffData = self.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffData) else {
            return nil
        }

        let ciImage = CIImage(bitmapImageRep: bitmapImage)
        guard let grayscale = ciImage?.applyingFilter("CIPhotoEffectMono") else {
            return nil
        }

        let rep = NSCIImageRep(ciImage: grayscale)
        let nsImage = NSImage(size: rep.size)
        nsImage.addRepresentation(rep)

        return nsImage
    }
}
