import SwiftUI
import PencilKit

struct TextInputView: View {
    @State private var canvasView = PKCanvasView()
    @State private var isDrawing = false
    @State private var showScribbleHint = true
    @State private var promptText = "A time you went crazy" // Example prompt
    @State private var promptIndex = 0
    @State private var prompts = [
        "A time you went crazy",
        "The best day of your life",
        "A place you want to visit",
        "Something funny that happened to you"
    ]

    var body: some View {
        ZStack {
            GridPatternBackground()
            VStack(spacing: 24) {
                // Prompt Bar (Top bar with changing prompt text)
                Text(promptText)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.top, 16)
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 5)
                
                // Main Content Area
                ZStack {
                    // Your sticky note image
                    Image("whiteNote1") // Replace with your asset
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .frame(width: 300, height: 300)
                        .rotationEffect(.degrees(-3))
                        .shadow(color: .gray.opacity(0.2), radius: 8, x: 0, y: 5)
                    
                    // Drawing canvas (appears on tap)
                    if isDrawing {
                        DrawingCanvasView(canvasView: $canvasView)
                            .frame(width: 300, height: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .transition(.opacity)
                    }
                    
                    // Hint when drawing is not active
                    if !isDrawing && showScribbleHint {
                        VStack(spacing: 6) {
                            Image(systemName: "pencil.tip.crop.circle")
                                .font(.system(size: 32))
                                .foregroundColor(.orange)
                            Text("Tap to draw")
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .onTapGesture {
                    withAnimation {
                        isDrawing = true
                        showScribbleHint = false
                    }
                }
                
                // Text input area below the sticky note
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemGray6))
                    .frame(height: 50)
                    .padding(.horizontal)
                    .overlay(
                        Text("Type something…")
                            .foregroundColor(.gray)
                            .padding(.horizontal),
                        alignment: .leading
                    )
            }
            .onAppear {
                startPromptTimer()
            }
        }
    }

    // Timer to change prompt every few seconds
    func startPromptTimer() {
        Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { _ in
            promptIndex = (promptIndex + 1) % prompts.count
            promptText = prompts[promptIndex]
        }
    }
}

#Preview {
    TextInputView()
}

// PencilKit wrapper
struct DrawingCanvasView: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView

    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = canvasView
        canvas.drawingPolicy = .anyInput
        canvas.backgroundColor = .clear
        canvas.tool = PKInkingTool(.pen, color: .black, width: 5)

        if UIApplication.shared.connectedScenes.first is UIWindowScene {
            let toolPicker = PKToolPicker()
            toolPicker.setVisible(true, forFirstResponder: canvas)
            toolPicker.addObserver(canvas)
            canvas.becomeFirstResponder()
        }

        return canvas
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        // Update logic here
    }
}
