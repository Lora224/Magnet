import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import PhotosUI
import SDWebImageSwiftUI

struct ProfileView: View {
    @State private var isSidebarVisible = false
    @State private var userName = ""
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
        NavigationStack {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    Image("MainBack")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                        .opacity(0.2)

                    VStack(spacing: 0) {
                        header
                        content(for: geometry)
                    }

                    if isSidebarVisible {
                        // Overlay that captures taps outside the sidebar
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                            .onTapGesture {
                                withAnimation { isSidebarVisible = false }
                            }
                            .zIndex(1) // Ensure it’s above content but below sidebar

                        // The sidebar itself
                        SideBarView()
                            .frame(width: 280)
                            .transition(.move(edge: .leading))
                            .zIndex(2) // Topmost so it receives touches
                    }
                }
                .onAppear {
                    loadUserName()
                    loadUserAvatar()
                    loadFamilies()
                }
                .photosPicker(isPresented: $isShowingImagePicker,
                              selection: $selectedImageItem,
                              matching: .images)
                .onChange(of: selectedImageItem) {
                    handleImageChange()
                }
            }
            .navigationBarHidden(true)
        }
    }

    // MARK: - Header
    private var header: some View {
        HStack {
            Button {
                withAnimation(.easeInOut) { isSidebarVisible.toggle() }
            } label: {
                Image(systemName: "line.3.horizontal")
                    .resizable()
                    .frame(width: 60, height: 30)
                    .foregroundColor(.magnetBrown)
                    .padding(16)
            }
            Spacer()
        }
        .padding(.top, 20)
    }

    // MARK: - Main Content
    private func content(for geometry: GeometryProxy) -> some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(spacing: 0) {
                ProfileAvatarView(avatarURL: avatarURL) {
                    isShowingImagePicker = true
                }
                .padding(.top, 8)

                TextField("Enter name", text: $userName) {
                    updateName()
                }
                .font(.title).bold()
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                )
                .frame(width: 240)
                .focused($nameFieldIsFocused)
                .padding(.top, 24)

                let maxWidth = min(geometry.size.width * 0.9, 600)
                familyGrid(maxWidth: maxWidth)
            }
            .padding(.bottom, 20)
        }
    }

    private func familyGrid(maxWidth: CGFloat) -> some View {
        LazyVGrid(columns: columns, spacing: 32) {
            ForEach(families) { fam in
                NavigationLink {
                    FamilyGroupView(
                        familyName: fam.name,
                        familyEmoji: "👨‍👩‍👧‍👦",
                        backgroundColor: Color(red: fam.red, green: fam.green, blue: fam.blue)
                    )
                } label: {
                    FamilyCard(family: fam, textColor: .magnetBrown)
                        .frame(width: 240, height: 240)
                }
                .buttonStyle(PlainButtonStyle())
            }

            NavigationLink {
                JoinCreate()
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 0, style: .continuous)
                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [6]))
                        .frame(width: 240, height: 240)
                    Image(systemName: "plus")
                        .font(.system(size: 36, weight: .semibold))
                        .foregroundColor(.magnetBrown)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 16)
        .padding(.top, 32)
        .padding(.bottom, 20)
        .frame(maxWidth: maxWidth)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Sidebar
    private var sidebar: some View {
        Group {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { withAnimation { isSidebarVisible = false } }
            SideBarView()
                .frame(width: 280)
                .transition(.move(edge: .leading))
                .zIndex(1)
        }
    }

    // MARK: - Actions
    private func updateName() {
        FirestoreManager.shared.updateCurrentUserName(to: userName) { result in
            if case .failure(let error) = result {
                print("Failed to update name: \(error)")
            }
        }
    }

    private func handleImageChange() {
        Task {
            if let data = try? await selectedImageItem?.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                UserProfileManager.shared.uploadUserProfilePicture(image: uiImage) { result in
                    if case .failure(let error) = result {
                        print("Failed to upload avatar: \(error)")
                    } else {
                        loadUserAvatar()
                    }
                }
            }
        }
    }

    // MARK: - Data Loading
    private func loadUserName() {
        FirestoreManager.shared.getCurrentUserName { result in
            DispatchQueue.main.async {
                if case .success(let name) = result {
                    userName = name
                } else {
                    userName = ""
                }
            }
        }
    }

    private func loadUserAvatar() {
        UserProfileManager.shared.fetchUserProfilePictureURL { result in
            DispatchQueue.main.async {
                if case .success(let urlString) = result,
                   let urlStr = urlString,
                   let url = URL(string: urlStr) {
                    avatarURL = url
                } else {
                    avatarURL = nil
                }
            }
        }
    }

    private func loadFamilies() {
        UserProfileManager.shared.fetchUserFamilies { result in
            DispatchQueue.main.async {
                if case .success(let fetched) = result {
                    families = fetched
                }
            }
        }
    }
}

#Preview{
    ProfileView()
}

