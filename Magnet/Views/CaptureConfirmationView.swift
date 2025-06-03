import SwiftUI

struct CaptureConfirmationView: View {
    @State private var caption: String = ""
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                GridPatternBackground()
                
                HStack {
                    VStack {
                        CircleActionButton(
                            systemImage: "xmark",
                            backgroundColor: Color(Color.red)
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
    
    // Using a placeholder image
    private let placeholderImage = Image("cameraPlaceholder")
    
    var body: some View {
        VStack(spacing: 0) {
            // Photo area with dynamic sizing
            ZStack {
                // Polaroid frame background
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 8)
                
                VStack(spacing: 0) {
                    // Image container
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
                    
                    // Caption area
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
        // Using a standard aspect ratio for placeholder
        let imageAspectRatio: CGFloat = 4.0 / 3.0 // Standard camera aspect ratio
        let availableImageHeight = maxHeight - 120 // Subtract space for caption and padding
        
        let imageWidth = min(availableImageHeight * imageAspectRatio, maxWidth - 40)
        return imageWidth + 40
    }
    
    private func calculatePolaroidHeight() -> CGFloat {
        return calculateImageHeight() + 120
    }
    
    private func calculateImageHeight() -> CGFloat {
        // Using a standard aspect ratio for placeholder
        let imageAspectRatio: CGFloat = 4.0 / 3.0 // Standard camera aspect ratio
        let polaroidWidth = calculatePolaroidWidth()
        let availableImageWidth = polaroidWidth - 40 // Subtract padding
        
        return availableImageWidth / imageAspectRatio
    }
    
    private func calculatePolaroidDimensions() {
        let width = calculatePolaroidWidth()
        let height = calculatePolaroidHeight()
        polaroidSize = CGSize(width: width, height: height)
    }
}

struct CircleActionButton: View {
    let systemImage: String
    let backgroundColor: Color
    let size: CGFloat
    
    init(systemImage: String, backgroundColor: Color, size: CGFloat = 80) {
        self.systemImage = systemImage
        self.backgroundColor = backgroundColor
        self.size = size
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(backgroundColor)
                .frame(width: size, height: size)
                .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 4)
            
            Image(systemName: systemImage)
                .font(.system(size: size * 0.4, weight: .bold))
                .foregroundColor(.white)
        }
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

struct GridPatternBackground: View {
    var body: some View {
        ZStack {
            Color(red: 0.96, green: 0.93, blue: 0.87)
                .ignoresSafeArea()
            
            // Grid pattern
            Canvas { context, size in
                let gridSpacing: CGFloat = 48
                
                context.stroke(
                    Path { path in
                        // Vertical lines
                        for x in stride(from: 0, through: size.width, by: gridSpacing) {
                            path.move(to: CGPoint(x: x, y: 0))
                            path.addLine(to: CGPoint(x: x, y: size.height))
                        }
                        
                        // Horizontal lines
                        for y in stride(from: 0, through: size.height, by: gridSpacing) {
                            path.move(to: CGPoint(x: 0, y: y))
                            path.addLine(to: CGPoint(x: size.width, y: y))
                        }
                    },
                    with: .color(Color.black.opacity(0.2)),
                    lineWidth: 0.5
                )
            }
        }
    }
}


#Preview {
    CaptureConfirmationView()
}
