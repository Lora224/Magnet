import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import PhotosUI
import SDWebImageSwiftUI

struct ProfileView: View {
    @State private var isSidebarVisible: Bool = false
    @State private var userName: String = ""
    @FocusState private var nameFieldIsFocused: Bool

    @State private var avatarURL: URL? = nil
    @State private var selectedImageItem: PhotosPickerItem? = nil
    @State private var isShowingImagePicker = false

    @State private var families: [Family] = [] 

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                VStack(spacing: 0) {
                    // Top navigation bar
                    HStack {
                        Button(action: {
                            withAnimation(.easeInOut) {
                                isSidebarVisible.toggle()
                            }
                        }) {
                            Image(systemName: "line.3.horizontal")
                                .resizable()
                                .frame(width: 60, height: 30)
                                .foregroundColor(.magnetBrown)
                                .padding(16)
                        }

                        Spacer()

                        NavigationLink(destination: MainView()) {
                            Image(systemName: "house.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .font(.title2)
                                .foregroundColor(.magnetBrown)
                                .padding(16)
                        }
                    }
                    .padding(.top, 20)

                    // Avatar + pencil overlay
                    ProfileAvatarView(
                        avatarURL: avatarURL
                    ) {
                        isShowingImagePicker = true
                    }
                    .padding(.top, 8)

                    // User name TextField
                    TextField("Enter name", text: $userName, onCommit: {
                        FirestoreManager.shared.updateCurrentUserName(to: userName) { result in
                            switch result {
                            case .success:
                                print("Name updated successfully.")
                            case .failure(let error):
                                print("Failed to update name: \(error)")
                            }
                        }
                    })
                    .font(.title)
                    .bold()
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 1.0)
                            )
                    )
                    .frame(width: 240)
                    .focused($nameFieldIsFocused)
                    .padding(.top, 24)

                    // Family grid 🚀
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 32) {
                            ForEach(families) { fam in
                                NavigationLink(
                                    destination: FamilyGroupView(
                                        familyName: fam.name,
                                        familyEmoji: "👨‍👩‍👧‍👦",
                                        backgroundColor: Color(red: fam.red, green: fam.green, blue: fam.blue)
                                    )
                                ) {
                                    FamilyCard(family: fam, textColor: .magnetBrown)
                                        .aspectRatio(1, contentMode: .fit)
                                        .frame(maxWidth: 240)
                                }
                            }

                            // Add family button
                            ZStack {
                                RoundedRectangle(cornerRadius: 0, style: .continuous)
                                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [6]))
                                    .aspectRatio(1, contentMode: .fit)
                                    .frame(maxWidth: 240)

                                Image(systemName: "plus")
                                    .font(.system(size: 36, weight: .semibold))
                                    .foregroundColor(.magnetBrown)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 32)
                        .frame(maxWidth: 600)
                        .frame(maxWidth: .infinity)
                    }

                    Spacer(minLength: 20)
                }
                .edgesIgnoringSafeArea(.bottom)
                .disabled(isSidebarVisible)
                .blur(radius: isSidebarVisible ? 2 : 0)
                .onAppear {
                    loadUserName()
                    loadUserAvatar()
                    loadFamilies() // 🚀 families
                }

                .photosPicker(isPresented: $isShowingImagePicker, selection: $selectedImageItem, matching: .images)
                .onChange(of: selectedImageItem) {
                    Task {
                        if let data = try? await selectedImageItem?.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {

                            UserProfileManager.shared.uploadUserProfilePicture(image: uiImage) { result in
                                switch result {
                                case .success(let url):
                                    print("Uploaded avatar to URL: \(url)")
                                    loadUserAvatar() // refresh avatar
                                case .failure(let error):
                                    print("Failed to upload avatar: \(error)")
                                }
                            }
                        }
                    }
                }

                // Sidebar
                if isSidebarVisible {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                isSidebarVisible = false
                            }
                        }
                }

                if isSidebarVisible {
                    SideBarView()
                        .frame(width: 280)
                        .transition(.move(edge: .leading))
                        .zIndex(1)
                }
            }
        }
    }

    private func loadUserName() {
        FirestoreManager.shared.getCurrentUserName { result in
            switch result {
            case .success(let name):
                DispatchQueue.main.async {
                    self.userName = name
                }
            case .failure(let error):
                print("Failed to fetch name: \(error)")
                DispatchQueue.main.async {
                    self.userName = ""
                }
            }
        }
    }

    private func loadUserAvatar() {
        UserProfileManager.shared.fetchUserProfilePictureURL { result in
            switch result {
            case .success(let urlString):
                if let urlString = urlString, let url = URL(string: urlString) {
                    DispatchQueue.main.async {
                        self.avatarURL = url
                    }
                } else {
                    DispatchQueue.main.async {
                        self.avatarURL = nil
                    }
                }
            case .failure(let error):
                print("Failed to fetch avatar URL: \(error)")
                DispatchQueue.main.async {
                    self.avatarURL = nil
                }
            }
        }
    }

    private func loadFamilies() {
        UserProfileManager.shared.fetchUserFamilies { result in
            switch result {
            case .success(let families):
                DispatchQueue.main.async {
                    self.families = families
                }
            case .failure(let error):
                print("Failed to fetch families: \(error)")
            }
        }
    }
}

