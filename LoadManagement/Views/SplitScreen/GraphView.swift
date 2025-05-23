//
//  GraphView.swift
//  LoadManagement
//
//  Created by Ásmundur Óskar Ásmundsson on 8.11.2024.
//

import SwiftUI
import Charts

struct GraphView: View {
    @Environment(RecordingViewModel.self) var recordingViewModel: RecordingViewModel

    @Binding var currentTime: Double
    @Binding var timeWindow: Double
    @Binding var dataCategory: String
    @Binding var currentSensor: Int
    @State var yAxisRange = -160.0...160.0
    
    var dataPointsWithinWindow: [(timestamp: Double, values: [String: Double])] {
        let lowerBound = currentTime - timeWindow / 2
        let upperBound = currentTime + timeWindow / 2
        guard let recording = recordingViewModel.recording else { return [] }
        let timestamps = recording.sensors[currentSensor].recordingData.getTimeStamp()
        
        let filteredIndices = timestamps.indices.filter { index in
            let timestamp = timestamps[index]
            return timestamp >= lowerBound && timestamp <= upperBound
        }
        
        let dataKeys = recordingViewModel.recording!.sensors[currentSensor].recordingData.getAvailableKeys(for: dataCategory)
        
        return filteredIndices.map { index in
            var values: [String: Double] = [:]
            for key in dataKeys {
                values[key] = recordingViewModel.recording!.sensors[currentSensor].recordingData.getData(for: key)[index]
            }
            return (timestamp: timestamps[index], values: values)
        }
    }
    
    var computedYAxisRange: ClosedRange<Double> {
        let dataKeys = recordingViewModel.recording!.sensors[currentSensor].recordingData.getAvailableKeys(for: dataCategory)
        let allValues = dataKeys.flatMap { recordingViewModel.recording!.sensors[currentSensor].recordingData.getData(for: $0) }
        guard let minY = allValues.min(), let maxY = allValues.max(), minY != maxY else {
            return -160...160
        }
        return minY...maxY
    }

    var body: some View {
        Chart {
            ForEach(dataPointsWithinWindow, id: \ .timestamp) { dataPoint in
                ForEach(dataPoint.values.keys.sorted(), id: \ .self) { key in
                    LineMark(
                        x: .value("Time", dataPoint.timestamp),
                        y: .value(key, dataPoint.values[key] ?? 0)
                    )
                    .foregroundStyle(by: .value("Axis", key))
                }
            }
            
            // Red line to mark the current time
            RuleMark(x: .value("Time", currentTime))
                .foregroundStyle(.red)
        }
        .chartXScale(domain: (currentTime - timeWindow / 2)...(currentTime + timeWindow / 2))
        .chartYScale(domain: yAxisRange)
        .onAppear { updateYAxisRange() }
        .onChange(of: dataCategory) { _, _ in updateYAxisRange() }
        .onChange(of: currentSensor) { _, _ in updateYAxisRange() }
        .padding()
    }

    private func updateYAxisRange() {
        yAxisRange = computedYAxisRange
    }
    
    init(currentTime: Binding<Double>, timeWindow: Binding<Double>, currentSensor: Binding<Int>, dataCategory: Binding<String>) {
        self._currentTime = currentTime
        self._timeWindow = timeWindow
        self._dataCategory = dataCategory
        self._currentSensor = currentSensor
    }
}

#Preview {
    @Previewable @State var sensor = 0
    @Previewable @State var previewCurrentTime: Double = 50.0
    @Previewable @State var previewTimeWindow: Double = 10.0
    @Previewable @State var previewDataCategory: String = "Acc"

    GraphView(
        currentTime: $previewCurrentTime,
        timeWindow: $previewTimeWindow,
        currentSensor: $sensor,
        dataCategory: $previewDataCategory
    )
}
