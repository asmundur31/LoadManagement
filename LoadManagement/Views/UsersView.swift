//
//  UsersView().swift
//  LoadManagement
//
//  Created by Ásmundur Óskar Ásmundsson on 3.12.2024.
//

import SwiftUI

struct UsersView: View {
    @State private var viewModel = UsersViewModel()
    @State private var isEditing = false
    @State private var selectedUser: User = User(id: 0, user_name: "Bull")
    @State private var newUsername = ""
    @State private var isCreatingNewUser = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Custom Toolbar
            HStack {
                Text("Users")
                    .font(.largeTitle)
                    .bold()
                Spacer()
                Button(action: {
                    isCreatingNewUser = true
                }) {
                    Image(systemName: "plus")
                        .font(.title2)
                }
            }
            .padding()
            .background(Color(UIColor.systemBackground))

            List(viewModel.users) { user in
                NavigationLink(destination: EditUserView(viewModel: viewModel, user: user)) {
                    HStack {
                        Text(user.user_name)
                        Spacer()
                    }
                    .contentShape(Rectangle())
                }
            }
            .listStyle(.plain)
        }
        .onAppear {
            viewModel.fetchUsers()
        }
        .sheet(isPresented: $isCreatingNewUser) {
            CreateUserView(isPresented: $isCreatingNewUser, viewModel: viewModel)
        }
    }
}

struct CreateUserView: View {
    @State private var newUserName: String = ""
    @Binding var isPresented: Bool
    let viewModel: UsersViewModel

    var body: some View {
        VStack(spacing: 16) {
            Text("Create New User")
                .font(.headline)
                .padding(.top)

            TextField("Enter Username", text: $newUserName)
                .textFieldStyle(.roundedBorder)
                .padding()

            HStack {
                Button("Cancel") {
                    isPresented = false // Dismiss view
                }
                .buttonStyle(.bordered)
                .padding()

                Spacer()

                Button("Create") {
                    if !newUserName.isEmpty {
                        viewModel.createUser(userName: newUserName)
                        isPresented = false // Dismiss view after creating
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }

            Spacer()
        }
        .padding()
    }
}


struct EditUserView: View {
    @Environment(\.dismiss) var dismiss
    let viewModel: UsersViewModel
    var user: User
    @State var newName: String = ""
    
    init(viewModel: UsersViewModel, user: User) {
        self.viewModel = viewModel
        self.user = user
        _newName = .init(initialValue: user.user_name)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Edit Username")
                .font(.headline)
                .padding(.top)
            TextField("New Username", text: $newName)
                .textFieldStyle(.roundedBorder)
                .padding()
            Spacer()
            HStack {
                Spacer()
                Button("Cancel") {
                    dismiss()
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray)
                .foregroundColor(.white)
                .cornerRadius(8)
                Spacer()
                Button("Save") {
                    viewModel.updateUser(userId: user.id, newUserName: newName)
                    dismiss()
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                Spacer()
            }
        }
        .padding()
    }
}

#Preview {
    NavigationStack {
        UsersView()
    }
}
