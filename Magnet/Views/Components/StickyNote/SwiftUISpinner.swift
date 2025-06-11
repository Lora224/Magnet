//
//  SwiftUISpinner.swift
//  Magnet
//
//  Created by Yutong Li on 9/6/2025.
//

import SwiftUI

struct SwiftUISpinner: View {
    @State private var isAnimating = false

    var body: some View {
        Circle()
            .trim(from: 0.0, to: 0.8)
            .stroke(lineWidth: 4)
            .frame(width: 30, height: 30)
            .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
            .onAppear {
                withAnimation(Animation.linear(duration: 1).repeatForever(autoreverses: false)) {
                    isAnimating = true
                }
            }
    }
}
