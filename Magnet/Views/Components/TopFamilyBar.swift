//
//  TopFamilyBar.swift
//  Magnet
//
//  Created by Yutong Li on 2/6/2025.
//



//
import SwiftUI

struct TopFamilyBar: View {
    private let magnetBrown   = Color(red: 0.294, green: 0.212, blue: 0.129) // #4B3621
    private let magnetPink    = Color(red: 0.945, green: 0.827, blue: 0.808) // #F1D3CE
    private let magnetYellow  = Color(red: 1.000, green: 0.961, blue: 0.855) // #FFF5DA
    private let magnetBlue    = Color(red: 0.820, green: 0.914, blue: 0.965) // #D1E9F6
    @State private var isSidebarVisible = false
    var body: some View {
        VStack {
            HStack {
                
                
                // Wrap the text and rectangle together
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
                        Button(action: {
                            withAnimation {
                                if(!isSidebarVisible){isSidebarVisible = true}
                                else {isSidebarVisible = false}
                                
                                
                            }
                        }) {
                            Image(systemName: "line.horizontal.3")
                                .resizable()
                                .frame(width: 60, height: 30)
                                .foregroundColor(magnetBrown)
                                .padding(.leading, 30)
                       }
                        Spacer()

                    }
                )

                
                   .frame(alignment: .top) // this line helps when inside a parent with defined height

            }
            .frame(maxWidth: .infinity, alignment: .top)
        }
        
        .ignoresSafeArea(.all, edges: .top)

        // Sidebar Overlay
      //1) dim other parts of the screen

            // 2) Sidebar content: sits above the dimming layer
            SideBarView()
                .frame(width: 280)              // fixed width
                .offset(y: 90)                  // positioned directly under the top bar
                .transition(.move(edge: .leading))
                .zIndex(1)                      // higher zIndex than the dimming
        

        


    }
}



#Preview(traits: .landscapeLeft) {
    TopFamilyBar()
}
