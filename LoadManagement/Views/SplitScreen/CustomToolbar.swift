//
//  CustomToolbar.swift
//  LoadManagement
//
//  Created by Ásmundur Óskar Ásmundsson on 8.11.2024.
//

import SwiftUI

struct CustomToolbar: View {
    @Environment(RecordingViewModel.self) var recordingViewModel: RecordingViewModel

    @State private var showSettingsSheet = false  // State to control the visibility of the settings overlay
    @Binding var currentTime: Double
    @Binding var timeWindow: Double
    @Binding var currentDataCategory: String
    @State var dataCategoryOptions: [String]
    @Binding var currentSensor: Int
    @State var sensorOptions: [String]
    @State var totalDataLength: Int
    @State var dataStartTime: Double
    @State var dataEndTime: Double
    @State var dataFrequency: Double
    @StateObject private var videoPlayerViewModel: VideoPlayerViewModel

    init(currentTime: Binding<Double>, currentTimeWindow: Binding<Double>, currentDataCategory: Binding<String>, currentSensor: Binding<Int>) {
        self._currentTime = currentTime
        self._timeWindow = currentTimeWindow
        self._currentDataCategory = currentDataCategory
        self._currentSensor = currentSensor
        
        self.sensorOptions = []
        self.totalDataLength = 0
        self.dataCategoryOptions = []
        self.dataFrequency = 1.0
        self.dataStartTime = 0.0
        self.dataEndTime = 10.0
        
        _videoPlayerViewModel = StateObject(wrappedValue: VideoPlayerViewModel(currentTime: currentTime))
    }
    
    var body: some View {
        VStack {
            HStack {
                Slider(value: $currentTime, in: dataStartTime...dataEndTime, step: dataFrequency) {
                    Text("Time Window")
                }
                Text(String(format: "%.2f", currentTime - dataStartTime))
                    .frame(width: 100)
            }
            
            HStack {
                VStack {
                    Picker("Data type", selection: $currentDataCategory) {
                        ForEach(dataCategoryOptions, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                }
                
                Spacer()
                HStack(spacing: 10) {
                    playbackButton("<<", action: { moveFrameBackward(10) })
                    playbackButton("<", action: { moveFrameBackward(1) })
                    playbackButton(videoPlayerViewModel.isPlaying ? "Pause" : "Play", action: videoPlayerViewModel.togglePlayPause, color: videoPlayerViewModel.isPlaying ? .red : .green)
                    playbackButton(">", action: { moveFrameForward(1) })
                    playbackButton(">>", action: { moveFrameForward(10) })
                }
                Spacer()
                VStack {
                    Picker("Sensor", selection: $currentSensor) {
                        ForEach(Array(sensorOptions.enumerated()), id: \.0) { index, sensorName in
                            Text(sensorName).tag(index)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                }
            }
            HStack {
                Button("Open Settings") {
                    showSettingsSheet = true
                }
                .sheet(isPresented: $showSettingsSheet) {
                    SettingsView(currentTime: $currentTime, timeWindow: $timeWindow, showSettings: $showSettingsSheet)
                }
            }
        }
        .padding()
        .background(Color.white)
        .shadow(radius: 2)
        .onAppear() {
            if let recording = recordingViewModel.recording {
                self.sensorOptions = recording.sensors.map { $0.getSensorName() }
                
                if currentSensor < recording.sensors.count {
                    let selectedSensor = recording.sensors[currentSensor]
                    self.totalDataLength = selectedSensor.recordingData.getTimeStamp().count
                    self.dataCategoryOptions = selectedSensor.recordingData.getDataTypes()
                    self.dataFrequency = selectedSensor.recordingInfo.getFrequency()
                    
                    let timestamps = selectedSensor.recordingData.getTimeStamp()
                    self.dataStartTime = timestamps.first ?? 0.0
                    self.dataEndTime = timestamps.last ?? 0.0
                } else {
                    // Handle the case where sensor index is out of bounds
                    self.totalDataLength = 0
                    self.dataCategoryOptions = []
                    self.dataFrequency = 0.0
                    self.dataStartTime = 0.0
                    self.dataEndTime = 0.0
                }
            }
        }
    }
    
    // Move the time back by one frame (based on data frequency)
    private func moveFrameBackward(_ number: Int) {
        currentTime = max(currentTime - Double(number)*dataFrequency, dataStartTime)
    }

    // Move the time forward by one frame (based on data frequency)
    private func moveFrameForward(_ number: Int) {
        currentTime = min(currentTime + Double(number)*dataFrequency, dataEndTime)
    }
    
    @ViewBuilder
    private func playbackButton(_ title: String, action: @escaping () -> Void, color: Color = .blue) -> some View {
        Button(action: action) {
            Text(title)
                .padding()
                .background(color)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
    }
}

#Preview {
    @Previewable @State var previewCurrentTime: Double = 12.0
    @Previewable @State var previewTimeWindow: Double = 10.0
    @Previewable @State var previewDataCategory: String = "Acc"
    @Previewable @State var previewSensor: Int = 0

    
    CustomToolbar(
        currentTime: $previewCurrentTime,
        currentTimeWindow: $previewTimeWindow,
        currentDataCategory: $previewDataCategory,
        currentSensor: $previewSensor
    )
}
