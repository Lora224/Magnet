import SwiftUI

struct CaptureConfirmationView: View {
    @State private var caption: String = ""
    
    var body: some View {
        GeometryReader { geometry in
            // Detect portrait vs. landscape
            let isPortrait = geometry.size.height > geometry.size.width
            
            ZStack {
                GridPatternBackground()
                
                if isPortrait {
                    // PORTRAIT: VStack layout, buttons at bottom with new dimensions
                    VStack {
                        // Top-left exit button
                        HStack {
                            CircleExitButton(
                                systemImage: "xmark",
                                backgroundColor: .red
                            )
                            Spacer()
                        }
                        .padding(.leading, 20)
                        .padding(.top, 20)
                        
                        Spacer()
                        
                        // Center Polaroid
                        PolaroidPhotoView(
                            caption: $caption,
                            maxWidth: min(geometry.size.width * 0.8, 650),
                            maxHeight: min(geometry.size.height * 0.6, 500)
                        )
                        
                        Spacer()
                        
                        // Bottom: two buttons side‐by‐side with “portrait” dimensions
                        HStack(spacing: 24) {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(red: 0.88, green: 0.80, blue: 0.70))
                                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                                // Portrait size: wider and shorter
                                .frame(width: 350, height:  100)
                                .overlay(
                                    RectangleButton(
                                        systemImage: "arrow.clockwise",
                                        color: Color(red: 75 / 255, green: 54 / 255, blue: 33 / 255)
                                    )
                                )
                            
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(red: 0.80, green: 1, blue: 0.85))
                                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                                // Portrait size: wider and shorter
                                .frame(width: 350, height: 100)
                                .overlay(
                                    RectangleButton(
                                        systemImage: "checkmark",
                                        color: Color(red: 0.2, green: 0.7, blue: 0.4)
                                    )
                                )
                        }
                        .padding(.bottom, 20)
                    }
                    
                } else {
                    // LANDSCAPE: original HStack with tall buttons on the right
                    HStack {
                        // Top-left exit button
                        VStack {
                            CircleExitButton(
                                systemImage: "xmark",
                                backgroundColor: .red
                            )
                            Spacer()
                        }
                        .padding(.leading, 20)
                        .padding(.top, 20)
                        
                        Spacer()
                        
                        // Center Polaroid
                        VStack {
                            Spacer()
                            PolaroidPhotoView(
                                caption: $caption,
                                maxWidth: min(geometry.size.width * 0.8, 650),
                                maxHeight: min(geometry.size.height * 0.9, 700)
                            )
                            Spacer()
                        }
                        
                        Spacer()
                        
                        // Right: two tall buttons stacked vertically
                        VStack(spacing: 24) {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color(red: 0.88, green: 0.80, blue: 0.70))
                                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                                .frame(width: 100, height: 350)
                                .overlay(
                                    RectangleButton(
                                        systemImage: "arrow.clockwise",
                                        color: Color(red: 75 / 255, green: 54 / 255, blue: 33 / 255)
                                    )
                                )
                            
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color(red: 0.80, green: 1, blue: 0.85))
                                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                                .frame(width: 100, height: 350)
                                .overlay(
                                    RectangleButton(
                                        systemImage: "checkmark",
                                        color: Color(red: 0.2, green: 0.7, blue: 0.4)
                                    )
                                )
                        }
                        .padding(.trailing, 16)
                        .padding([.top, .bottom], 20)
                    }
                }
            }
        }
    }
}



// MARK: - Preview

#Preview{
    CaptureConfirmationView()
}
