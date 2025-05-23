//
//  Sensor.swift
//  LoadManagement
//
//  Created by Ásmundur Óskar Ásmundsson on 7.11.2024.
//

import Foundation

protocol Sensor: Decodable {
    associatedtype Data: RecordingData
    associatedtype Info: RecordingInfo
    
    var recordingData: Data { get }
    var recordingInfo: Info { get }
    
    func getSensorName() -> String
    
    static func mock(count: Int, startTime: Double) -> RecordingData
    static func mock0(count: Int, startTime: Double) -> RecordingData
}

protocol RecordingInfo: Decodable {
    var recordingID: String { get }
    var recordingName: String { get }
    var sensorName: String { get }
    var frequency: Double { get }
    var jumpCount: Int { get }
    
    func getInfo() -> [String: Any]
    func getFrequency() -> Double
}

protocol RecordingData: Decodable {
    var timestamp: [Double] { get }
    var accX: [Double] { get }
    var accY: [Double] { get }
    var accZ: [Double] { get }
    var gyroX: [Double] { get }
    var gyroY: [Double] { get }
    var gyroZ: [Double] { get }
    
    func getTimeStamp() -> [Double]
    func getData(for type: String) -> [Double]
    func getAvailableKeys(for type: String) -> [String]
    func getDataTypes() -> [String]
}
