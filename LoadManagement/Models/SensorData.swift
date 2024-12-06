//
//  SensorData.swift
//  LoadManagement
//
//  Created by Ásmundur Óskar Ásmundsson on 5.11.2024.
//

import Foundation

struct SensorData: Identifiable {
    var id = UUID().uuidString
    var timestamp: Double
    var acceleration: (x: Double, y: Double, z: Double)
    var gyro: (x: Double, y: Double, z: Double)
    var magnometer: (x: Double, y: Double, z: Double)
    
    static func mock(count: Int, startTime: Double) -> [SensorData] {
        var mockData = [SensorData]()
        for id in 0..<count {
            mockData.append(
                SensorData(
                    timestamp: startTime+Double(id),
                    acceleration: (Double.random(in: -10...10), Double.random(in: -10...10), Double.random(in: -10...10)),
                    gyro: (Double.random(in: -10...10), Double.random(in: -10...10), Double.random(in: -10...10)),
                    magnometer: (Double.random(in: -10...10), Double.random(in: -10...10), Double.random(in: -10...10))
                )
            )
        }
        return mockData
    }
    
    static func mock0data(count: Int, startTime: Double) -> [SensorData] {
        var mockData = [SensorData]()
        for id in 0..<count {
            mockData.append(
                SensorData(
                    timestamp: startTime+Double(id),
                    acceleration: (0,0,0),
                    gyro: (0,0,0),
                    magnometer: (0,0,0)
                )
            )
        }
        return mockData
    }
    
    static func convertData(accData: [String], gyroData: [String], magnData: [String]) -> (sensorData: [SensorData], frequency: Double) {
        var sensorData: [SensorData] = []
        for ((acc, gyro), magn) in zip(zip(accData, gyroData), magnData) {
            let accValues = acc.components(separatedBy: ",")
            let gyroValues = gyro.components(separatedBy: ",")
            let magnValues = magn.components(separatedBy: ",")
            if accValues.count == 4,
               let timestamp = Double(accValues[0]),
               let accX = Double(accValues[1]),
               let accY = Double(accValues[2]),
               let accZ = Double(accValues[3]),
               gyroValues.count == 4,
               let gyroX = Double(gyroValues[1]),
               let gyroY = Double(gyroValues[2]),
               let gyroZ = Double(gyroValues[3]),
               magnValues.count == 4,
               let magnX = Double(magnValues[1]),
               let magnY = Double(magnValues[2]),
               let magnZ = Double(magnValues[3]) {
                let sensorDataPoint = SensorData(timestamp: timestamp, acceleration: (accX, accY, accZ), gyro: (gyroX, gyroY, gyroZ), magnometer: (magnX, magnY, magnZ))
                sensorData.append(sensorDataPoint)
            } else {
                print("Warning: Line format incorrect or values are not numbers - \(acc) - \(gyro) - \(magn)")
            }
        }
        let (fixedData, frequency) = fixTimestamps(sensorData: sensorData)
        return (fixedData, frequency)
    }
    
    static func fixTimestamps(sensorData: [SensorData]) -> ([SensorData], Double) {
        // Edge case: if there's only one data point, no fixing needed
        guard sensorData.count > 1 else { return (sensorData, 0.0) }
        
        var fixedData = sensorData
        var frequency: Double = 0.0
        var numberOfFrequencies: Int = 0

        var j = 0
        for i in 1..<sensorData.count {
            if sensorData[i].timestamp != sensorData[i-1].timestamp {
                let n = i-j // Number of datapoints
                let frequencyNow = (sensorData[i].timestamp - sensorData[i-1].timestamp) / Double(n)
                j = i - n
                while j < i - 1 {
                    fixedData[j].timestamp -= (Double((i-j-1))*frequencyNow)
                    j += 1
                }
                j += 1
                numberOfFrequencies += 1
                frequency += frequencyNow
            }
        }
        return (fixedData, frequency/Double(numberOfFrequencies))
    }
}
