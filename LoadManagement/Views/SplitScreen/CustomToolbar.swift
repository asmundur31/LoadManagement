//
//  CustomToolbar.swift
//  LoadManagement
//
//  Created by Ásmundur Óskar Ásmundsson on 8.11.2024.
//

import SwiftUI

struct CustomToolbar: View {
    @State private var showSettingsSheet = false  // State to control the visibility of the settings overlay
    @Binding var currentTime: Double
    @Binding var timeWindow: Double
    @Binding var dataCategory: String
    var dataCategoryOptions: [String] = ["Acc", "Gyro", "Magn"]
    @Binding var sensorId: String
    var sensorOptions: [Sensor]
    var totalDataLength: Int
    var dataStartTime: Double
    var dataEndTime: Double
    var dataFrequency: Double
    @Binding var videos: [VideoData]
    @StateObject private var videoPlayerViewModel: VideoPlayerViewModel

    init(currentTime: Binding<Double>, timeWindow: Binding<Double>, dataCategory: Binding<String>, sensorId: Binding<String>, sensors: [Sensor], totalDataLength: Int, dataStartTime: Double, dataEndTime: Double, dataFrequency: Double, videos: Binding<[VideoData]>) {
        self._currentTime = currentTime
        self._timeWindow = timeWindow
        self._dataCategory = dataCategory
        self._sensorId = sensorId
        self.sensorOptions = sensors
        self.totalDataLength = totalDataLength
        self.dataStartTime = dataStartTime
        self.dataEndTime = dataEndTime
        self.dataFrequency = dataFrequency
        self._videoPlayerViewModel = StateObject(wrappedValue: VideoPlayerViewModel(currentTime: currentTime))
        self._videos = videos
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
                    Picker("Options", selection: $dataCategory) {
                        ForEach(dataCategoryOptions, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                }
                
                Spacer()
                Button(action: {
                    moveFrameBackward(10)
                }) {
                   Text("<<")
                       .padding()
                       .background(Color.blue)
                       .foregroundColor(.white)
                       .cornerRadius(8)
                }
                Button(action: {
                    moveFrameBackward(1)
                }) {
                   Text("<")
                       .padding()
                       .background(Color.blue)
                       .foregroundColor(.white)
                       .cornerRadius(8)
                }
                Button(action: videoPlayerViewModel.togglePlayPause) {
                    Text(videoPlayerViewModel.isPlaying ? "Pause" : "Play")
                       .padding()
                       .background(videoPlayerViewModel.isPlaying ? Color.red : Color.green)
                       .foregroundColor(.white)
                       .cornerRadius(8)
                }
                Button(action: {
                    moveFrameForward(1)
                }) {
                   Text(">")
                       .padding()
                       .background(Color.blue)
                       .foregroundColor(.white)
                       .cornerRadius(8)
                }
                Button(action: {
                    moveFrameForward(10)
                }) {
                   Text(">>")
                       .padding()
                       .background(Color.blue)
                       .foregroundColor(.white)
                       .cornerRadius(8)
                }
                Spacer()
                VStack {
                    Picker("Options", selection: $sensorId) {
                        ForEach(sensorOptions) { sensor in
                            Text(sensor.id).tag(sensor.id)
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
                    SettingsView(timeWindow: $timeWindow, showSettings: $showSettingsSheet, videos: $videos)
                }
            }
        }
        .padding()
        .background(Color.white)
        .shadow(radius: 2)
        .onAppear() {
            videoPlayerViewModel.dataFrequency = dataFrequency
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
}

struct SettingsView: View {
    @Binding var timeWindow: Double
    @Binding var showSettings: Bool
    @Binding var videos: [VideoData]
    
    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    Text("Settings")
                        .font(.title)
                        .padding()
                    VStack {
                        HStack {
                            Text("Window size:")
                            Slider(value: $timeWindow, in: 1...50, step: 1)
                                .padding()
                            Text(String(format: "%.2f", timeWindow))
                            
                        }
                        HStack {
                            Button(action: {
                                timeWindow -= 0.1
                            }) {
                                Text("-")
                                    .font(.title)
                                    .padding()
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .clipShape(Circle())
                            }
                            Text(String(format: "%.2f", timeWindow))
                                .font(.title)
                                .padding(.horizontal, 20)
                            
                            Button(action: {
                                timeWindow += 0.1
                            }) {
                                Text("+")
                                    .font(.title)
                                    .padding()
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .clipShape(Circle())
                            }
                        }
                    }
                    
                    ForEach(videos.indices, id: \.self) { index in
                        VStack {
                            HStack {
                                Text("Start time adjustment (video \(index + 1)):")
                                Slider(value: $videos[index].startTimeAdjustment, in: -10...10, step: 0.1)
                                    .padding()
                                Text(String(format: "%.2f", videos[index].startTimeAdjustment))
                            }
                            HStack {
                                Button(action: {
                                    videos[index].startTimeAdjustment -= 0.01
                                }) {
                                    Text("-")
                                        .font(.title)
                                        .padding()
                                        .background(Color.red)
                                        .foregroundColor(.white)
                                        .clipShape(Circle())
                                }
                                
                                Text(String(format: "%.2f", videos[index].startTimeAdjustment))
                                    .font(.title)
                                    .padding(.horizontal, 20)
                                
                                Button(action: {
                                    videos[index].startTimeAdjustment += 0.01
                                }) {
                                    Text("+")
                                        .font(.title)
                                        .padding()
                                        .background(Color.green)
                                        .foregroundColor(.white)
                                        .clipShape(Circle())
                                }
                            }
                        }
                    }
                    
                    Button("Close Settings") {
                        showSettings = false  // Close the overlay when the button is tapped
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding()
                Spacer()
            }
        }
        .edgesIgnoringSafeArea(.all)  // Make sure it covers the entire screen
    }
}

#Preview {
    @Previewable @State var previewCurrentTime: Double = 23.0
    @Previewable @State var previewTimeWindow: Double = 10.0
    @Previewable @State var previewDataCategory: String = "Acc"
    @Previewable @State var previewSensorId: String = "1234567890"
    @Previewable @State var videoSegments = [
        VideoData(url: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!, startTime: 23, startTimeAdjustment: 0.0, endTime: 38, duration: 15),
        VideoData(url: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4")!, startTime: 69, startTimeAdjustment: 0.0, endTime: 84, duration: 15)
    ]
    let totalDataLength = 1000
    let dataStartTime = 0.0
    let dataEndTime = 1000.0
    let dataFrequency = 1.0
    
    CustomToolbar(
        currentTime: $previewCurrentTime,
        timeWindow: $previewTimeWindow,
        dataCategory: $previewDataCategory,
        sensorId: $previewSensorId,
        sensors: [],
        totalDataLength: totalDataLength,
        dataStartTime: dataStartTime,
        dataEndTime: dataEndTime,
        dataFrequency: dataFrequency,
        videos: $videoSegments
    )
}
