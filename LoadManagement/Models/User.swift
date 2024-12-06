//
//  User.swift
//  LoadManagement
//
//  Created by Ásmundur Óskar Ásmundsson on 4.12.2024.
//

import Foundation

struct User: Identifiable, Codable, Hashable {
    let id: Int
    var user_name: String
}
