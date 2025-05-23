//
//  VideoData.swift
//  LoadManagement
//
//  Created by Ásmundur Óskar Ásmundsson on 5.11.2024.
//

import Foundation

struct VideoData: Identifiable {
    var id = UUID()
    var url: URL
    var startTime: Double
    var startTimeAdjustment: Double
    var playbackSpeed: Double
    var duration: Double
}
