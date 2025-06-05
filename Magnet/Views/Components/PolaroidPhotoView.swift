//
//  PolaroidPhotoView.swift
//  Magnet
//
//  Created by Muze Lyu on 5/6/2025.
//

import SwiftUI

struct PolaroidPhotoView: View {
    @Binding var caption: String
    let maxWidth: CGFloat
    let maxHeight: CGFloat
    
    @State private var polaroidSize: CGSize = .zero
    private let placeholderImage = Image("cameraPlaceholder")
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 8)
                
                VStack(spacing: 0) {
                    ZStack {
                        Color.black.opacity(0.05)
                        
                        placeholderImage
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
                    .frame(height: calculateImageHeight())
                    
                    VStack {
                        TextField("Enter caption here...", text: $caption)
                            .font(.system(size: 24, weight: .regular, design: .serif))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                        
                        Spacer(minLength: 0)
                    }
                    .frame(height: 80)
                    .padding(.bottom, 20)
                }
            }
            .frame(width: calculatePolaroidWidth(), height: calculatePolaroidHeight())
        }
        .onAppear {
            calculatePolaroidDimensions()
        }
    }
    
    private func calculatePolaroidWidth() -> CGFloat {
        let imageAspectRatio: CGFloat = 4.0 / 3.0
        let availableImageHeight = maxHeight - 120
        let imageWidth = min(availableImageHeight * imageAspectRatio, maxWidth - 40)
        return imageWidth + 40
    }
    
    private func calculatePolaroidHeight() -> CGFloat {
        calculateImageHeight() + 120
    }
    
    private func calculateImageHeight() -> CGFloat {
        let imageAspectRatio: CGFloat = 4.0 / 3.0
        let polaroidWidth = calculatePolaroidWidth()
        let availableImageWidth = polaroidWidth - 40
        return availableImageWidth / imageAspectRatio
    }
    
    private func calculatePolaroidDimensions() {
        let width = calculatePolaroidWidth()
        let height = calculatePolaroidHeight()
        polaroidSize = CGSize(width: width, height: height)
    }
}
