import SwiftUI
import PencilKit

struct TextInputView: View {
    @State private var canvasView = PKCanvasView()
    @State private var isDrawing = false
    @State private var showScribbleHint = true
    @State private var selectedColor = Color.black
    @State private var blockedAreaHeight: CGFloat = 30
    @State private var typedNote: String = ""

    @State private var promptText = "What made you smile/laugh today?😊"
    @State private var promptIndex = 0
    @State private var prompts = [
        "What frustrated you most today?😤",
        "What did you eat today?🍝",
        "How did the weather affect your mood today?🌞",
        "What was the best part of your day?✨"
    ]

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                GridPatternBackground()

                // Main layout
                HStack {
                    VStack {
                        // Exit button
                        CircleExitButton(
                            systemImage: "xmark",
                            backgroundColor: Color.red
                        )
                        .padding(.top, 20)
                        .padding(.leading, 16)
                        Spacer()
                    }
                    Spacer()

                    VStack(spacing: 24) {
                        Text(promptText)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .padding([.top, .bottom], 24)
                            .frame(width: 560)
                            .background(Color.white)
                            .cornerRadius(15)
                            .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 5)

                        ZStack {
                            Image("whiteNote1")
                                .resizable()
                                .aspectRatio(1, contentMode: .fit)
                                .frame(width: 480, height: 480)
                                .shadow(color: .gray.opacity(0.2), radius: 8, x: 0, y: 5)

                            if isDrawing {
                                DrawingCanvasView(canvasView: $canvasView)
                                    .frame(width: 420, height: 420)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .mask(
                                        Rectangle()
                                            .frame(width: 420, height: 420)
                                            .overlay(
                                                Rectangle()
                                                    .frame(width: 420, height: blockedAreaHeight)
                                                    .blendMode(.destinationOut),
                                                alignment: .top
                                            )
                                    )
                            }

                            if !isDrawing && showScribbleHint {
                                VStack(spacing: 6) {
                                    Image(systemName: "pencil.tip.crop.circle")
                                        .font(.system(size: 50))
                                        .foregroundColor(Color(red: 0.88, green: 0.80, blue: 0.70))
                                    Text("Tap to draw")
                                        .font(.body)
                                        .foregroundColor(Color(red: 75 / 255, green: 54 / 255, blue: 33 / 255))
                                }
                            }
                        }
                        .onTapGesture {
                            withAnimation {
                                isDrawing = true
                                showScribbleHint = false
                                setTool(.pen)
                            }
                        }

                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                            )
                            .frame(width: 560, height: 50)
                            .overlay(
                                TextField("Type something…", text: $typedNote)
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 32),
                                alignment: .leading
                            )

                        if isDrawing {
                            HStack(spacing: 20) {
                                Button(action: { setTool(.pen) }) {
                                    Image(systemName: "pencil.tip")
                                }

                                Button(action: { setTool(.eraser) }) {
                                    Image(systemName: "eraser")
                                }

                                ColorPicker("", selection: $selectedColor, supportsOpacity: false)
                                    .labelsHidden()
                                    .frame(width: 40, height: 40)
                                    .background(Circle().fill(selectedColor))
                                    .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                                    .onChange(of: selectedColor) {
                                        setTool(.pen)
                                    }
                            }
                            .padding()
                            .background(Color.white.opacity(0.95))
                            .cornerRadius(12)
                            .shadow(radius: 5)
                        }
                    }
                    .frame(maxWidth: 600)
                    .frame(height: geometry.size.height)
                    .frame(maxHeight: .infinity)

                    Spacer()

                    VStack {
                        Spacer()
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(red: 0.80, green: 1, blue: 0.85))
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                            .frame(width: 100)
                            .frame(maxHeight: .infinity)
                            .padding([.top, .bottom], 20)
                            .overlay(
                                RectangleButton(
                                    systemImage: "checkmark",
                                    color: Color(red: 0.2, green: 0.7, blue: 0.4)
                                )
                            )
                        Spacer()
                    }
                    .padding(.trailing, 16)
                }
                .onAppear {
                    startPromptTimer()
                }
            }
        }
    }

    func setTool(_ type: ToolType) {
        switch type {
        case .pen:
            canvasView.tool = PKInkingTool(.pen, color: UIColor(selectedColor), width: 5)
        case .eraser:
            canvasView.tool = PKEraserTool(.vector)
        }
    }

    enum ToolType {
        case pen, eraser
    }

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

struct DrawingCanvasView: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView

    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = canvasView
        canvas.drawingPolicy = .anyInput
        canvas.backgroundColor = .clear
        return canvas
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
}
