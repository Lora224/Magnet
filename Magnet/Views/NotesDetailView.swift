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
    private let lightGray     = Color(red: 0.98, green: 0.98, blue: 0.98) // very light gray
    

    var body: some View {
        VStack(spacing: 0) {
            
            // Header bar
            VStack(spacing: 0) {
                TopFamilyBar()
            }
            
            ZStack(alignment: .topLeading) {
                
                // Centered Sticky Note
                Image("blueNotePlain")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 700, height: 700)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .offset(y: -20)
                    .shadow(color: Color.black.opacity(0.10),
                            radius: 15,
                            x: 10,
                            y: 10)
                
                Image("blueNotePlain")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 700, height: 700)
                    .offset(x: 1000, y: -20) // Moves it to the right
                    .zIndex(0)
                    .shadow(color: Color.black.opacity(0.10),
                            radius: 15,
                            x: 10,
                            y: 10)
                
                Image("blueNotePlain")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 700, height: 700)
                    .offset(x: -500, y: -20) // Moves it to the right
                    .zIndex(0)
                    .shadow(color: Color.black.opacity(0.10),
                            radius: 15,
                            x: 10,
                            y: 10)
                
                // Back Arrow at Top-Left
                Image(systemName: "arrowshape.backward.fill")
                    .font(.system(size: 50))
                    .padding(.top, 10)
                    .padding(.leading, 30)
                
                Image("image") // Profile Picture
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120)
                    .offset(x: 550, y: 15)
                    .zIndex(1)
            }
            .frame(height: 500) // or any height you prefer
            Spacer()


            ZStack {
                // 1) Rounded rectangle as the “container”
                RoundedRectangle(cornerRadius: 35)
                    .fill(lightGray)
                    .frame(width: 500, height: 80)

                // 2) HStack of magnets, centered inside that rectangle
                HStack(spacing: 90) {
                    Image("heartMagnet")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)

                    Image("clapMagnet")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)

                    Image("laughMagnet")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                }
            }
            
            Image(systemName: "chevron.compact.up")
                .font(.system(size: 60))
                .foregroundColor(magnetBrown)
                .offset(y: 20)   // ← shifts just the chevron 20 points down

    
        }
        .ignoresSafeArea(.all, edges: .top)
    }
}

#Preview {
    NotesDetailView()
}




