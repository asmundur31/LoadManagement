//
//  Sensor.swift
//  LoadManagement
//
//  Created by Ásmundur Óskar Ásmundsson on 7.11.2024.
//

import Foundation

struct Sensor: Identifiable {
    var id: String
    var frequency: Double
    var data: [SensorData]
}
