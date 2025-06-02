//
//  MainView.swift
//  Magnet
//
//  Created by Muze Lyu on 30/5/2025.
//
//Main View of the project


import SwiftUI

struct MainView: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                TopFamilyBar()
                Spacer()
            }

            ZStack {
                Image("blueNoteLines")
                    .resizable()
                    .frame(width: 250, height: 250)
                    .position(x: 500, y: 230)
                    .rotationEffect(.degrees(-8))

                Image("blueNoteLines")
                    .resizable()
                    .frame(width: 250, height: 250)
                    .position(x: 800, y: 230)
                    .rotationEffect(.degrees(7))

                Image("pinkNote")
                    .resizable()
                    .frame(width: 250, height: 250)
                    .position(x: 700, y: 490)
                    .rotationEffect(.degrees(-8))

                Image("yellowNote")
                    .resizable()
                    .frame(width: 250, height: 250)
                    .position(x: 440, y: 470)
                    .rotationEffect(.degrees(-6))
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        print("Plus tapped!")
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 70, height: 70)
                            .foregroundStyle(Color.magnetBrown)
                            .shadow(radius: 6)
                    }
                    Spacer()
                }
                .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    MainView()
}
