import SwiftUI
import SwiftData

struct FamilyManagerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var families: [Family]

    @State private var name: String = ""
    @State private var inviteURL: String = ""
    @State private var memberText: String = ""
    @State private var red: Double = 1.0
    @State private var green: Double = 0.96
    @State private var blue: Double = 0.85

    var body: some View {
        VStack {
            Form {
                Section(header: Text("Create a New Family")) {
                    TextField("Family Name", text: $name)
                    TextField("Invite URL", text: $inviteURL)
                    TextField("Member IDs (comma-separated)", text: $memberText)
                    ColorPicker("Choose Color", selection: Binding(
                        get: { Color(red: red, green: green, blue: blue) },
                        set: { newColor in
                            if let components = UIColor(newColor).cgColor.components {
                                red = components[0]
                                green = components.count >= 3 ? components[1] : components[0]
                                blue = components.count >= 3 ? components[2] : components[0]
                            }
                        }
                    ))
                    Button("Add Family") {
                        addFamily()
                    }
                    .disabled(name.isEmpty || inviteURL.isEmpty)
                }
            }

            Divider()
            
            if families.isEmpty {
                Text("No families yet.")
                .foregroundColor(.gray)
                .padding()
            }

            List {
                ForEach(families) { family in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(family.name).font(.headline)
                        Text("Invite URL: \(family.inviteURL)").font(.caption)
                        Text("Members: \(family.memberIDs.joined(separator: ", "))").font(.subheadline)
                        Text(String(format: "Color RGB: R %.2f, G %.2f, B %.2f", family.red, family.green, family.blue))
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Rectangle()
                            .fill(family.swiftUIColor)
                            .frame(height: 10)
                            .cornerRadius(5)

                        HStack {
                            Spacer()
                            Button(role: .destructive) {
                                deleteFamily(family)
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                                    .padding(6)
                                    .background(Color(.systemGray6))
                                    .clipShape(Circle())
                            }
                        }
                    }
                    .padding(8)
                }
            }
        }
    }

    private func addFamily() {
        let members = memberText.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }

        let newFamily = Family(
            name: name,
            inviteURL: inviteURL,
            memberIDs: members,
            red: red,
            green: green,
            blue: blue
        )
        modelContext.insert(newFamily)

        name = ""
        inviteURL = ""
        memberText = ""
        red = 1.0
        green = 0.96
        blue = 0.85
    }

    private func deleteFamily(_ family: Family) {
        modelContext.delete(family)
    }
}

#Preview{
    FamilyManagerView()
}
