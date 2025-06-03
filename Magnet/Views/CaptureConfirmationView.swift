import SwiftUI

struct CaptureConfirmationView: View {
    @State private var caption: String = ""
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                GridPatternBackground()
                
                HStack {
                    VStack {
                        // → Replaced: use CircleExitButton instead of CircleActionButton
                        CircleExitButton(
                            systemImage: "xmark",
                            backgroundColor: .red
                        )
                        Spacer()
                    }
                    .padding(.leading, 20)
                    .padding(.top, 20)
                    
                    Spacer()
                    
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
                    
                    VStack {
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
                        
                        Spacer()

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
        return calculateImageHeight() + 120
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

struct RectangleButton: View {
    let systemImage: String
    let color: Color
    let size: CGFloat

    init(systemImage: String, color: Color, size: CGFloat = 40) {
        self.systemImage = systemImage
        self.color = color
        self.size = size
    }

    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: size, weight: .bold))
            .foregroundColor(color)
    }
}

#Preview {
    CaptureConfirmationView()
}
