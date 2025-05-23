//
//  MariahSensor.swift
//  LoadManagement
//
//  Created by Ásmundur Óskar Ásmundsson on 24.1.2025.
//

import Foundation

struct MariahSensor: Sensor {
    let recordingInfo: MariahRecordingInfo
    let recordingData: MariahRecordingData
    
    enum CodingKeys: String, CodingKey {
        case recordingInfo = "recording_info"
        case recordingData = "recording_data"
    }
    
    func getSensorName() -> String {
        return recordingInfo.sensorName
    }
    
    static func mock(count: Int, startTime: Double) -> RecordingData {
        var mockData = MariahRecordingData()
        for id in 0..<count {
            mockData.timestamp.append(startTime + Double(id))
            mockData.accX.append(Double.random(in: -10...10))
            mockData.accY.append(Double.random(in: -10...10))
            mockData.accZ.append(Double.random(in: -10...10))
            mockData.gyroX.append(Double.random(in: -10...10))
            mockData.gyroY.append(Double.random(in: -10...10))
            mockData.gyroZ.append(Double.random(in: -10...10))
            mockData.hr.append(Double.random(in: -10...10))
        }
        return mockData
    }
    
    static func mock0(count: Int, startTime: Double) -> RecordingData {
        var mockData = MariahRecordingData()
        for id in 0..<count {
            mockData.timestamp.append(startTime + Double(id))
            mockData.accX.append(0.0)
            mockData.accY.append(0.0)
            mockData.accZ.append(0.0)
            mockData.gyroX.append(0.0)
            mockData.gyroY.append(0.0)
            mockData.gyroZ.append(0.0)
            mockData.hr.append(0.0)
        }
        return mockData
    }
}

struct MariahRecordingInfo: RecordingInfo {
    var jumpCount: Int
    let frequency: Double
    let wodUUID: String
    let recordingID: String
    let recordingType: String
    let recordingName: String
    let userUUID: String
    let startDate: String
    let sensorName: String
    let recordingService: String
    let sensorLocation: String
    let complete: Bool
    let userScore: String
    let finishDate: String
    let userComment: String
    let userRPE: Int
    
    func getInfo() -> [String : Any] {
        return [
            "frequency": frequency/1000,
            "wodUUID": wodUUID,
            "recordingID": recordingID,
            "recordingType": recordingType,
            "recordingName": recordingName,
            "userUUID": userUUID,
            "startDate": startDate,
            "sensorName": sensorName,
            "recordingService": recordingService,
            "sensorLocation": sensorLocation,
            "complete": complete,
            "userScore": userScore,
            "finishDate": finishDate,
            "userComment": userComment,
            "userRPE": userRPE,
            "jumpCount": jumpCount
        ]
    }
    
    func getFrequency() -> Double {
        return frequency/1000
    }
    
    enum CodingKeys: String, CodingKey {
        case frequency
        case wodUUID = "wod_uuid"
        case sensorName = "sensor_mac_address"
        case recordingID = "recording_uuid"
        case recordingType = "recording_type"
        case recordingName = "wod_title"
        case userUUID = "user_uuid"
        case startDate = "start_date"
        case recordingService = "recording_service"
        case sensorLocation = "sensor_location"
        case complete
        case userScore = "user_score"
        case finishDate = "finish_date"
        case userComment = "user_comment"
        case userRPE = "user_rpe"
        case jumpCount = "jump_count"
    }
}

struct MariahRecordingData: RecordingData {
    var timestamp: [Double] = []
    var accX: [Double] = []
    var accY: [Double] = []
    var accZ: [Double] = []
    var gyroX: [Double] = []
    var gyroY: [Double] = []
    var gyroZ: [Double] = []
    var hr: [Double] = []
    
    func getTimeStamp() -> [Double] {
        return timestamp.map { $0 / 1000 }
    }
    
    func getData(for type: String) -> [Double] {
        switch type {
        case "accX":
            return accX
        case "accY":
            return accY
        case "accZ":
            return accZ
        case "gyroX":
            return gyroX
        case "gyroY":
            return gyroY
        case "gyroZ":
            return gyroZ
        case "hr":
            return hr
        default:
            return []
        }
    }
    
    func getAvailableKeys(for type: String) -> [String] {
        switch type {
        case "Acc":
            return ["accX", "accY", "accZ"]
        case "Gyro":
            return ["gyroX", "gyroY", "gyroZ"]
        case "HR":
            return ["hr"]
        default:
            return []
        }
    }
    
    func getDataTypes() -> [String] {
        return ["Acc", "Gyro", "HR"]
    }
}
