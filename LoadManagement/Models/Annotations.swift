//
//  Annotations.swift
//  LoadManagement
//
//  Created by Ásmundur Óskar Ásmundsson on 5.11.2024.
//

import Foundation

struct Annotation: Decodable {
    var recording_info: RecordingInfoAnnotation
    var recording_data: AnnotationData
    
    func getVideoStartTimes() -> [Double] {
        return recording_data.type.enumerated().compactMap { (index, type) in
            (type == "VideoAnnotationStart") ? recording_data.timestamp[index] : nil
        }
    }
    
    func getVideoEndTimes() -> [Double] {
        return recording_data.type.enumerated().compactMap { (index, type) in
            (type == "VideoAnnotationStop") ? recording_data.timestamp[index] : nil
        }
    }
}

struct RecordingInfoAnnotation: Decodable {
    var recordingID: String
    var recordingName: String
    var userID: String
    var frequency: Double
    
    func getInfo() -> [String : Any] {
        return [
            "recordingID": recordingID,
            "frequency": frequency,
            "recordingName": recordingName
        ]
    }
    
    enum CodingKeys: String, CodingKey {
        case recordingID = "recording_id"
        case recordingName = "recording_name"
        case userID = "user_id"
        case frequency
    }
}



struct AnnotationData: Decodable {
    var timestamp: [Double] = []
    var type: [String] = []
    var content: [String] = []
}
