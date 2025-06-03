import SwiftUI

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
