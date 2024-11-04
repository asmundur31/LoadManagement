//
//  Item.swift
//  LoadManagement
//
//  Created by Ásmundur Óskar Ásmundsson on 4.11.2024.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
