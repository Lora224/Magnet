//
//  TopFamilyBar.swift
//  Magnet
//
//  Created by Yutong Li on 2/6/2025.
//

//
//  CalendarView.swift
//  Magnet
//
//  Created by Muze Lyu on 30/5/2025.
//

//
import SwiftUI

struct TopFamilyBar: View {
    private let magnetBrown   = Color(red: 0.294, green: 0.212, blue: 0.129) // #4B3621
    private let magnetPink    = Color(red: 0.945, green: 0.827, blue: 0.808) // #F1D3CE
    private let magnetYellow  = Color(red: 1.000, green: 0.961, blue: 0.855) // #FFF5DA
    private let magnetBlue    = Color(red: 0.820, green: 0.914, blue: 0.965) // #D1E9F6

    var body: some View {
        VStack {
            HStack {
                
                
                // Wrap the text and rectangle together
                ZStack {
                        Rectangle()
                            .fill(magnetYellow)
                            .frame(height: 100)

                        // Centered chevrons + emoji + title
                        HStack(spacing: 10) {
                            Button(action:{/*tbd*/}){
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 50))
                            }
                            Text("🎉")
                                .font(.system(size: 50))
                                .padding(.leading, 35)

                            Text("Family 1")
                                .font(.system(size: 50, weight: .bold))
                                .foregroundColor(magnetBrown)
                                .textCase(.uppercase)
                                .padding(.trailing, 35)

                            Button(action:{/*tbd*/}){
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 50))
                            }
                                
                        }
                        .font(.system(size: 20)) // Default symbol size if not individually set
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .overlay(
                        HStack {
                            NavigationLink(destination: SideBarView()) {
                                Image(systemName: "line.3.horizontal")
                                    .resizable()
                                    .frame(width: 80, height: 50)
                                    .foregroundColor(magnetBrown)
                                    .padding(.leading, 16)
                            }
                            Spacer()

                            Image(systemName: "ellipsis") // Invisible to balance layout
                                .opacity(0)
                                .padding(.trailing, 16)
                        }
                    )

                
                .frame(maxHeight: .infinity, alignment: .top) // this line helps when inside a parent with defined height

            }
            .frame(maxWidth: .infinity, alignment: .top)
        }
        .ignoresSafeArea(.all, edges: .top)
    }
}



#Preview(traits: .landscapeLeft) {
    CalendarView()
}
