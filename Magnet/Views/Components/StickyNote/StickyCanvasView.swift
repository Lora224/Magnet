import SwiftUI

struct StickyCanvasView: View {
    @ObservedObject var stickyManager: StickyDisplayManager

    @Binding var canvasOffset: CGSize
    @Binding var zoomScale: CGFloat
    @GestureState private var dragDelta: CGSize = .zero
    @Binding var families: [Family]
    @Binding var selectedFamilyIndex: Int
    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .gesture(
                    DragGesture()
                        .updating($dragDelta) { value, state, _ in
                            state = value.translation
                        }
                        .onEnded { value in
                            canvasOffset.width += value.translation.width
                            canvasOffset.height += value.translation.height
                        }
                )
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            zoomScale = min(max(value, 0.8), 2.5)
                        }
                )

            ZStack {
                ForEach(stickyManager.viewportNotes) { positioned in
                    StickyNoteView(note: positioned.note, reactions: positioned.reactions,  families: $families,  selectedFamilyIndex: $selectedFamilyIndex)
                        .rotationEffect(positioned.rotationAngle)
                        .position(positioned.position)
                        .id(positioned.id)
                        .zIndex(1)
                }
            }
            .offset(x: canvasOffset.width + dragDelta.width,
                    y: canvasOffset.height + dragDelta.height)
            .scaleEffect(zoomScale)
            .drawingGroup() 
        }
    }
}

