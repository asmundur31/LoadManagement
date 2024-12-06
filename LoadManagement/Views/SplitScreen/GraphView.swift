//
//  GraphView.swift
//  LoadManagement
//
//  Created by Ásmundur Óskar Ásmundsson on 8.11.2024.
//

import SwiftUI
import Charts

struct GraphView: View {
    @Binding var currentTime: Double
    @Binding var timeWindow: Double
    @Binding var dataCategory: String
    @Binding var sensor: Sensor
    @State var yAxisRange = 0.0...10.0
    var accYAxisRange: ClosedRange<Double> {
        let yValues = sensor.data.flatMap { [$0.acceleration.x, $0.acceleration.y, $0.acceleration.z] }
        let minY = yValues.min() ?? 0
        let maxY = yValues.max() ?? 1
        return minY...maxY
    }
    var gyroYAxisRange: ClosedRange<Double> {
        let yValues = sensor.data.flatMap { [$0.gyro.x, $0.gyro.y, $0.gyro.z] }
        let minY = yValues.min() ?? 0
        let maxY = yValues.max() ?? 1
        return minY...maxY
    }
    var magnYAxisRange: ClosedRange<Double> {
        let yValues = sensor.data.flatMap { [$0.magnometer.x, $0.magnometer.y, $0.magnometer.z] }
        let minY = yValues.min() ?? 0
        let maxY = yValues.max() ?? 1
        return minY...maxY
    }
    var filteredDataPoints: [SensorData] {
        sensor.data.filter { dataPoint in
                let lowerBound = currentTime - timeWindow/2
                let upperBound = currentTime + timeWindow/2
                return dataPoint.timestamp >= lowerBound && dataPoint.timestamp <= upperBound
            }
        }

    var body: some View {
        Chart {
            if dataCategory == "Acc" {
                // Acc data
                ForEach(filteredDataPoints) { d in
                    LineMark(
                        x: .value("Time", d.timestamp),
                        y: .value("Acceleration X", d.acceleration.x)
                    )
                    .lineStyle(.init(lineWidth: 3))
                    .foregroundStyle(by: .value("Acc", "X"))
                }
                ForEach(filteredDataPoints) { d in
                    LineMark(
                        x: .value("Time", d.timestamp),
                        y: .value("Acceleration Y", d.acceleration.y)
                    )
                    .lineStyle(.init(lineWidth: 3))
                    .foregroundStyle(by: .value("Acc", "Y"))
                }
                ForEach(filteredDataPoints) { d in
                    LineMark(
                        x: .value("Time", d.timestamp),
                        y: .value("Acceleration Z", d.acceleration.z)
                    )
                    .lineStyle(.init(lineWidth: 3))
                    .foregroundStyle(by: .value("Acc", "Z"))
                }
            } else if dataCategory == "Gyro" {
                // Gyro data
                ForEach(filteredDataPoints) { d in
                    LineMark(
                        x: .value("Time", d.timestamp),
                        y: .value("Gyro X", d.gyro.x)
                    )
                    .lineStyle(.init(lineWidth: 3))
                    .foregroundStyle(by: .value("Gyro", "X"))
                }
                ForEach(filteredDataPoints) { d in
                    LineMark(
                        x: .value("Time", d.timestamp),
                        y: .value("Gyro Y", d.gyro.y)
                    )
                    .lineStyle(.init(lineWidth: 3))
                    .foregroundStyle(by: .value("Gyro", "Y"))
                }
                ForEach(filteredDataPoints) { d in
                    LineMark(
                        x: .value("Time", d.timestamp),
                        y: .value("Gyro Z", d.gyro.z)
                    )
                    .lineStyle(.init(lineWidth: 3))
                    .foregroundStyle(by: .value("Gyro", "Z"))
                }
            } else if dataCategory == "Magn" {
                // Magnometer data
                ForEach(filteredDataPoints) { d in
                    LineMark(
                        x: .value("Time", d.timestamp),
                        y: .value("Magnometer X", d.magnometer.x)
                    )
                    .lineStyle(.init(lineWidth: 3))
                    .foregroundStyle(by: .value("Magn", "X"))
                }
                ForEach(filteredDataPoints) { d in
                    LineMark(
                        x: .value("Time", d.timestamp),
                        y: .value("Magnometer Y", d.magnometer.y)
                    )
                    .lineStyle(.init(lineWidth: 3))
                    .foregroundStyle(by: .value("Magn", "Y"))
                }
                ForEach(filteredDataPoints) { d in
                    LineMark(
                        x: .value("Time", d.timestamp),
                        y: .value("Magnometer Z", d.magnometer.z)
                    )
                    .lineStyle(.init(lineWidth: 3))
                    .foregroundStyle(by: .value("Magn", "Z"))
                }
            }
            // Red line to mark the current time
            RuleMark(
                x: .value("Time", currentTime)
            )
            .foregroundStyle(.red)
            .lineStyle(.init(lineWidth: 1))
        }
        .chartXScale(
            domain: (currentTime - timeWindow/2)...(currentTime + timeWindow/2)
        )
        .chartYScale(domain: yAxisRange)
        .chartYAxis {
            AxisMarks(values: .automatic)
        }
        .chartLegend(position: .leading, alignment: .bottom)
        .padding()
        .onAppear {
            if dataCategory == "Acc" {
                yAxisRange = accYAxisRange
            } else if dataCategory == "Gyro" {
                yAxisRange = gyroYAxisRange
            } else if dataCategory == "Magn" {
                yAxisRange = magnYAxisRange
            }
        }
        .onChange(of: dataCategory) { oldValue, newValue in
            if newValue == "Acc" {
                yAxisRange = accYAxisRange
            } else if newValue == "Gyro" {
                yAxisRange = gyroYAxisRange
            } else if newValue == "Magn" {
                yAxisRange = magnYAxisRange
            }
        }
    }
    
    init(currentTime: Binding<Double>, timeWindow: Binding<Double>, sensor: Binding<Sensor>, dataCategory: Binding<String>) {
        self._currentTime = currentTime
        self._timeWindow = timeWindow
        self._sensor = sensor
        self._dataCategory = dataCategory
    }
}

#Preview {
    @Previewable @State var sensor: Sensor = Sensor(id: "1234567890", frequency: 1.0/104.0, data: SensorData.mock(count: 100, startTime: 23))
    @Previewable @State var previewCurrentTime: Double = 50.0
    @Previewable @State var previewTimeWindow: Double = 10.0
    @Previewable @State var previewDataCategory: String = "Acc"
    
    GraphView(
        currentTime: $previewCurrentTime,
        timeWindow: $previewTimeWindow,
        sensor: $sensor,
        dataCategory: $previewDataCategory
    )
}
