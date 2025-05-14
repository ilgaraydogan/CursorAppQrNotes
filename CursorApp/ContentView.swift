//
//  ContentView.swift
//  CursorApp
//
//  Created by Bayram Ilgar Aydoğan on 14.05.2025.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct ContentView: View {
    @State private var noteText: String = ""
    @State private var qrImage: Image?

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("QR Notes")
                    .font(.largeTitle)
                    .padding(.top)

                TextField("Enter your note here", text: $noteText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                Button("Generate QR") {
                    generateQRCode()
                }
                .padding()
                .buttonStyle(.borderedProminent)

                if let qrImage = qrImage {
                    qrImage
                        .resizable()
                        .interpolation(.none) // Keeps the QR code sharp
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .contextMenu { // Added for easy saving
                            Button {
                                if let uiImage = convertImageToUIImage() {
                                    UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
                                }
                            } label: {
                                Label("Save to Photos", systemImage: "square.and.arrow.down")
                            }
                        }
                } else {
                    Spacer() // Takes up space if no QR code is shown
                        .frame(height: 200)
                }
                
                Spacer() // Pushes content to the top

            }
            .navigationBarHidden(true) // Hides the navigation bar for a cleaner look
            .padding()
        }
    }

    func generateQRCode() {
        guard !noteText.isEmpty else {
            self.qrImage = nil // Clear previous QR code if text is empty
            return
        }
        
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        let data = Data(noteText.utf8)

        filter.setValue(data, forKey: "inputMessage")

        // Improve QR code quality by upscaling
        let transform = CGAffineTransform(scaleX: 10, y: 10)

        if let outputImage = filter.outputImage?.transformed(by: transform) {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                // SwiftUI Image directly from CGImage
                self.qrImage = Image(cgimg, scale: 1.0, orientation: .up, label: Text("QR Code"))
                return
            }
        }
        self.qrImage = nil // Clear if generation fails
    }

    // Helper to convert SwiftUI Image back to UIImage for saving (if needed)
    // This specific implementation might need adjustment depending on how qrImage is created
    // For now, we'll regenerate the UIImage from noteText for simplicity for saving
    func convertImageToUIImage() -> UIImage? {
        guard !noteText.isEmpty else { return nil }
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        let data = Data(noteText.utf8)
        filter.setValue(data, forKey: "inputMessage")
        let transform = CGAffineTransform(scaleX: 10, y: 10)

        if let outputImage = filter.outputImage?.transformed(by: transform) {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }
        return nil
    }
}

#Preview {
    ContentView()
}
