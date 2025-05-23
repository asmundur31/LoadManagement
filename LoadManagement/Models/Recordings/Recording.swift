//
//  Recording.swift
//  LoadManagement
//
//  Created by Ásmundur Óskar Ásmundsson on 17.12.2024.
//

import Foundation

struct Recording {
    var videos: [VideoData]
    var sensors: [any Sensor]
}

struct RecordingWithZip: Decodable {
    var recording: RecordingDTO
    var zip_url: String
}

struct RecordingDTO: Decodable {
    var id: Int
    var recording_name: String
    var user_id: Int
    var uploaded_at: String
}

struct RecordingWithUser: Decodable {
    var recording_id: Int
    var recording_name: String
    var user_name: String
    var uploaded_at: String
}

