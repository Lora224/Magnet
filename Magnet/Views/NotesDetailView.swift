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

                }
            )
            
            ZStack(alignment: .topLeading) {
                
                // Centered Sticky Note
                Image("blueNotePlain")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 700, height: 700)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .offset(y: 100)
                    .shadow(color: Color.black.opacity(0.10),
                            radius: 15,
                            x: 10,
                            y: 10)
                
                Image("blueNotePlain")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 700, height: 700)
                    .offset(x: 1000, y: 100) // Moves it to the right
                    .zIndex(0)
                    .shadow(color: Color.black.opacity(0.10),
                            radius: 15,
                            x: 10,
                            y: 10)
                
                Image("blueNotePlain")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 700, height: 700)
                    .offset(x: -450, y: 100) // Moves it to the right
                    .zIndex(0)
                    .shadow(color: Color.black.opacity(0.10),
                            radius: 15,
                            x: 10,
                            y: 10)
                
                // Back Arrow at Top-Left
                Image(systemName: "arrowshape.backward.fill")
                    .font(.system(size: 50))
                    .padding(.top, 120)
                    .padding(.leading, 40)
                
                Image("image") // Profile Picture
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120)
                    .offset(x: 550, y: 130)
                    .zIndex(1)
            }
            .frame(height: 500) // or any height you prefer
            Spacer()


            ZStack {
                // 1) Rounded rectangle as the “container”
                RoundedRectangle(cornerRadius: 25)
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
    
        }
        .ignoresSafeArea(.all, edges: .top)
    }
}

#Preview {
    NotesDetailView()
}




