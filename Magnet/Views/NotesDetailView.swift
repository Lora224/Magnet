//
//  NotesDetailView.swift
//  Magnet
//
//  Created by Muze Lyu on 30/5/2025.
//

//For checking notes details from the main view
import SwiftUI

struct NotesDetailView: View {
    
    // Hex-based colors as properties
    private let magnetBrown   = Color(red: 0.294, green: 0.212, blue: 0.129) // #4B3621
    private let magnetPink    = Color(red: 0.945, green: 0.827, blue: 0.808) // #F1D3CE
    private let magnetYellow  = Color(red: 1.000, green: 0.961, blue: 0.855) // #FFF5DA
    private let magnetBlue    = Color(red: 0.820, green: 0.914, blue: 0.965) // #D1E9F6
    private let lightGray     = Color(red: 0.9, green: 0.9, blue: 0.9) // very light gray


    

    var body: some View {
        VStack(spacing: 0) {
            
            // Header bar
            ZStack {
                Rectangle()
                    .fill(magnetYellow)
                    .frame(height: 90)

                HStack(spacing: 10) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 40))

                    Text("🎉")
                        .font(.system(size: 45))
                        .padding(.leading, 35)

                    Text("Family 1")
                        .font(.system(size: 45, weight: .bold))
                        .foregroundColor(magnetBrown)
                        .textCase(.uppercase)
                        .padding(.trailing, 35)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 40))
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .overlay(
                HStack {
                    Image(systemName: "line.horizontal.3")
                        .resizable()
                        .frame(width: 65, height: 35)
                        .foregroundColor(magnetBrown)
                        .padding(.leading, 40)

                    Spacer()

                    Image(systemName: "ellipsis")
                        .opacity(0)
                        .padding(.trailing, 16)
                }
            )

            // Content row: back arrow, profile image, sticky note
            HStack {
                Image(systemName: "arrowshape.backward.fill")
                    .font(.system(size: 50))
                    .padding(.leading, 30)

                Spacer()

                Image("image") // Profile Picture
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100)
                    .padding(.top, 20)

                Image("blueNotePlain") // Sticky note
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 480, height: 480)

                Spacer()
            }
            .frame(maxWidth: .infinity)

            // Rounded rectangle at top of its section
            RoundedRectangle(cornerRadius: 25)
                .fill(lightGray)
                .frame(width: 400, height: 60)
                .padding(.top, 20)

            Spacer()
        }
        .ignoresSafeArea(.all, edges: .top)
    }
}

#Preview {
    NotesDetailView()
}



