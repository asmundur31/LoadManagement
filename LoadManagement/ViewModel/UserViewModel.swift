//
//  UserViewModel.swift
//  LoadManagement
//
//  Created by Ásmundur Óskar Ásmundsson on 3.12.2024.
//

import Foundation

@Observable
class UsersViewModel {
    var users: [User] = []
    
    func fetchUsers() {
        APIService.shared.fetchUsers { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let users):
                    self?.users = users
                case .failure(let error):
                    print("Error fetching users: \(error.localizedDescription)")
                }
            }
        }
    }

    func updateUser(userId: Int, newUserName: String) {
        APIService.shared.updateUserName(userId: userId, newUserName: newUserName) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    if let index = self.users.firstIndex(where: { $0.id == userId }) {
                        self.users[index].user_name = newUserName
                    }
                case .failure(let error):
                    print("Error updating user: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func createUser(userName: String) {
        APIService.shared.addUser(userName: userName) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    // If success then we get all users again
                    self.fetchUsers()
                case .failure(let error):
                    print("Error updating user: \(error.localizedDescription)")
                }
            }
        }
    }
}
