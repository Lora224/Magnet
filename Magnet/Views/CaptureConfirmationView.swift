import SwiftUI

// MARK: – CaptureConfirmationView

/// Displays a captured photo with options to retake or confirm (save).
/// Adapts UI layout for portrait and landscape, as in the provided design.
struct CaptureConfirmationView: View {

    let image: UIImage
    let onRetake: () -> Void
    let onConfirm: (UIImage) -> Void
    

    // ‣ A local caption field (if you want to let user type a caption)
    @State private var caption: String = ""

    var body: some View {
        GeometryReader { geometry in
            let isPortrait = geometry.size.height > geometry.size.width

            ZStack {
                //background
                GridPatternBackground()

                if isPortrait {
                    // ‣ PORTRAIT LAYOUT
                    VStack {
                        // Top-left “Retake/Exit” button
                        HStack {
                            CameraCircleExitButton(
                                systemImage: "xmark",
                                backgroundColor: .red,
                                action: onRetake
                            )
                            Spacer()
                        }
                        .padding(.leading, 20)
                        .padding(.top, 20)

                        Spacer()

                        PolaroidPhotoView(
                            image: image,
                            caption: $caption,
                            maxWidth: min(geometry.size.width * 0.8, 650),
                            maxHeight: min(geometry.size.height * 0.6, 500)
                        )
                        Spacer()

                        // Bottom row: Retake & Confirm buttons
                        HStack(spacing: 24) {
                            // Retake button
                            Button(action: onRetake) {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(red: 0.88, green: 0.80, blue: 0.70))
                                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                                    .frame(width: 350, height: 100)
                                    .overlay(
                                        CameraRectangleButton(
                                            systemImage: "arrow.clockwise",
                                            color: Color(red: 75/255, green: 54/255, blue: 33/255)
                                        )
                                    )
                            }

                            // Confirm button
                            Button(action: { onConfirm(image) }) {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(red: 0.80, green: 1, blue: 0.85))
                                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                                    .frame(width: 350, height: 100)
                                    .overlay(
                                        CameraRectangleButton(
                                            systemImage: "checkmark",
                                            color: Color(red: 0.2, green: 0.7, blue: 0.4)
                                        )
                                    )
                            }
                        }
                        .padding(.bottom, 20)
                    }
                } else {
                    // ‣ LANDSCAPE LAYOUT
                    HStack {
                        // Top-left “Retake/Exit” in a VStack
                        VStack {
                            CameraCircleExitButton(
                                systemImage: "xmark",
                                backgroundColor: .red,
                                action: onRetake
                            )
                            Spacer()
                        }
                        .padding(.leading, 20)
                        .padding(.top, 20)

                        Spacer()

                        VStack {
                            Spacer()
                            PolaroidPhotoView(
                                image: image,
                                caption: $caption,
                                maxWidth: min(geometry.size.width * 0.8, 650),
                                maxHeight: min(geometry.size.height * 0.9, 700)
                            )
                            Spacer()
                        }

                        Spacer()

                        // Right side: Retake & Confirm stacked vertically
                        VStack(spacing: 24) {
                            // Retake
                            Button(action: onRetake) {
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color(red: 0.88, green: 0.80, blue: 0.70))
                                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                                    .frame(width: 100, height: 350)
                                    .overlay(
                                        CameraRectangleButton(
                                            systemImage: "arrow.clockwise",
                                            color: Color(red: 75/255, green: 54/255, blue: 33/255)
                                        )
                                    )
                            }

                            // Confirm
                            Button(action: { onConfirm(image) }) {
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color(red: 0.80, green: 1, blue: 0.85))
                                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                                    .frame(width: 100, height: 350)
                                    .overlay(
                                        CameraRectangleButton(
                                            systemImage: "checkmark",
                                            color: Color(red: 0.2, green: 0.7, blue: 0.4)
                                        )
                                    )
                            }
                        }
                        .padding(.trailing, 16)
                        .padding([.top, .bottom], 20)
                    }
                }
            }
        }
    }
}

// MARK: – Helper Button Views

/// Circular “exit/retake” button
struct CameraCircleExitButton: View {
    let systemImage: String
    let backgroundColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(backgroundColor)
                    .frame(width: 60, height: 60)
                    .shadow(radius: 5)
                Image(systemName: systemImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
                    .foregroundColor(.white)
                    
            }
            
        }
    }
}

/// Simple overlay icon for rectangle buttons
struct CameraRectangleButton: View {
    let systemImage: String
    let color: Color

    var body: some View {
        Image(systemName: systemImage)
            .resizable()
            .scaledToFit()
            .frame(width: 30, height: 30)
            .foregroundColor(color)
    }
}

// MARK: – Preview

struct CaptureConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        // Supply a dummy UIImage (replace “example” with a valid asset name)
        CaptureConfirmationView(
            image: UIImage(named: "example") ?? UIImage(),
            onRetake: { },
            onConfirm: { _ in }
        )
    }
}
