//
//  Untitled.swift
//  LoadManagement
//
//  Created by Ásmundur Óskar Ásmundsson on 24.1.2025.
//

import Foundation

struct MySensor: Sensor {
    var recordingInfo: MyRecordingInfo
    var recordingData: MyRecordingData
    
    enum CodingKeys: String, CodingKey {
        case recordingInfo = "recording_info"
        case recordingData = "recording_data"
    }
    
    func getSensorName() -> String {
        return recordingInfo.sensorName
    }
    
    static func mock(count: Int, startTime: Double) -> RecordingData {
        var mockData = MyRecordingData()
        for id in 0..<count {
            mockData.timestamp.append(startTime + Double(id))
            mockData.accX.append(Double.random(in: -10...10))
            mockData.accY.append(Double.random(in: -10...10))
            mockData.accZ.append(Double.random(in: -10...10))
            mockData.gyroX.append(Double.random(in: -10...10))
            mockData.gyroY.append(Double.random(in: -10...10))
            mockData.gyroZ.append(Double.random(in: -10...10))
            mockData.magnX.append(Double.random(in: -10...10))
            mockData.magnY.append(Double.random(in: -10...10))
            mockData.magnZ.append(Double.random(in: -10...10))
        }
        return mockData
    }
    
    static func mock0(count: Int, startTime: Double) -> RecordingData {
        var mockData = MyRecordingData()
        for id in 0..<count {
            mockData.timestamp.append(startTime + Double(id))
            mockData.accX.append(0.0)
            mockData.accY.append(0.0)
            mockData.accZ.append(0.0)
            mockData.gyroX.append(0.0)
            mockData.gyroY.append(0.0)
            mockData.gyroZ.append(0.0)
            mockData.magnX.append(0.0)
            mockData.magnY.append(0.0)
            mockData.magnZ.append(0.0)
        }
        return mockData
    }
}

struct MyRecordingInfo: RecordingInfo {
    let recordingID: String
    let recordingName: String
    let userID: String
    let sensorName: String
    let frequency: Double
    let jumpCount: Int
    
    func getInfo() -> [String : Any] {
        return [
            "recordingID": recordingID,
            "recordingName": recordingName,
            "userID": userID,
            "sensorName": sensorName,
            "frequency": frequency,
            "jumpCount": jumpCount
        ]
    }
    func getFrequency() -> Double {
        return frequency
    }
    
    enum CodingKeys: String, CodingKey {
        case recordingID = "recording_id"
        case recordingName = "recording_name"
        case userID = "user_id"
        case sensorName = "sensor_name"
        case frequency
        case jumpCount = "jump_count"
    }
}

struct MyRecordingData: RecordingData {
    var timestamp: [Double] = []
    var accX: [Double] = []
    var accY: [Double] = []
    var accZ: [Double] = []
    var gyroX: [Double] = []
    var gyroY: [Double] = []
    var gyroZ: [Double] = []
    var magnX: [Double] = []
    var magnY: [Double] = []
    var magnZ: [Double] = []
    
    func getTimeStamp() -> [Double] {
        return timestamp
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
        case "magnX":
            return magnX
        case "magnY":
            return magnY
        case "magnZ":
            return magnZ
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
        case "Magn":
            return ["magnX", "magnY", "magnZ"]
        default:
            return []
        }
    }
    
    func getDataTypes() -> [String] {
        return ["Acc", "Gyro", "Magn"]
    }
    
    enum CodingKeys: String, CodingKey {
        case timestamp
        case accX = "accx"
        case accY = "accy"
        case accZ = "accz"
        case gyroX = "gyrox"
        case gyroY = "gyroy"
        case gyroZ = "gyroz"
        case magnX = "magnx"
        case magnY = "magny"
        case magnZ = "magnz"
    }
}
