//
//  SplitscreenView.swift
//  LoadManagement
//
//  Created by Ásmundur Óskar Ásmundsson on 6.11.2024.
//

import SwiftUI

struct SplitscreenView: View {
    @State private var currentTime: Double
    @State private var timeWindow: Double
    var directoryUrl: URL
    private var sensors: [Sensor]
    @State private var currentSensor: Sensor
    @State private var videos: [VideoData]
    private var annotations: [Annotation]
    
    // State for adjusting the split view
    @State private var videoWidthRatio: CGFloat = 0.5
    @State private var videoHeightRatio: CGFloat = 0.5
    
    // For changing data category
    @State private var dataCategory: String = "Acc"
    @State private var sensorId: String = ""
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                if geometry.size.width > geometry.size.height {
                    // Landscape - side by side layout
                    HStack(spacing: 0) {
                        // Video frame takes up a fraction of the width based on videoWidthRatio
                        VideoFrameView(segments: videos, currentTime: $currentTime)
                            .frame(width: geometry.size.width * videoWidthRatio)
                            .background(Color.black) // Add background color for visual separation
                        
                        Divider()
                            .frame(width: 5, height: geometry.size.height)
                            .background(Color.gray)
                            .gesture(
                                DragGesture(coordinateSpace: .global)
                                    .onChanged { value in
                                        // Calculate new width ratio based on drag location
                                        let dragLocationX = value.location.x / geometry.size.width
                                        videoWidthRatio = min(max(dragLocationX, 0.2), 0.8) // Limit to 20%-80% range
                                    }
                            )
                        
                        // Graph view takes up the remaining width
                        GraphView(currentTime: $currentTime, timeWindow: $timeWindow, sensor: $currentSensor, dataCategory: $dataCategory)
                            .frame(width: geometry.size.width * (1 - videoWidthRatio))
                            .background(Color.white) // Add background color for visual separation
                    }
                } else {
                    // Portrait - stacked layout
                    VStack(spacing: 0) {
                        VideoFrameView(segments: videos, currentTime: $currentTime)
                            .frame(height: geometry.size.height * videoHeightRatio)
                            .background(Color.black) // Add background color for visual separation
                        
                        Divider()
                            .frame(width: geometry.size.width, height: 5)
                            .background(Color.gray)
                            .gesture(
                                DragGesture(coordinateSpace: .global)
                                    .onChanged { value in
                                        // Calculate new width ratio based on drag location
                                        let dragLocationY = value.location.y / geometry.size.height
                                        videoHeightRatio = min(max(dragLocationY, 0.2), 0.8) // Limit to 20%-80% range
                                    }
                            )
                        
                        GraphView(currentTime: $currentTime, timeWindow: $timeWindow, sensor: $currentSensor, dataCategory: $dataCategory)
                            .frame(height: geometry.size.height * (1-videoHeightRatio))
                            .background(Color.white) // Add background color for visual separation
                    }
                }
            }
            
            CustomToolbar(
                currentTime: $currentTime,
                timeWindow: $timeWindow,
                dataCategory: $dataCategory,
                sensorId: $sensorId,
                sensors: sensors,
                totalDataLength: currentSensor.data.count,
                dataStartTime: currentSensor.data.first!.timestamp,
                dataEndTime: currentSensor.data.last!.timestamp,
                dataFrequency: currentSensor.frequency,
                videos: $videos
            )
        }
        .navigationTitle("Splitscreen View")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear() {
            let dataViewModel = DataViewModel()
            Task {
                videos = await dataViewModel.getVideos(directoryUrl: directoryUrl)
            }

        }
        .onChange(of: sensorId) { oldValue, newValue in
            if let matchingSensor = sensors.first(where: { $0.id == newValue }) {
                currentSensor = matchingSensor
            } else {
                print("No sensor found with ID \(newValue)")
            }
        }
    }
    
    init(timeWindow: Double, directoryUrl: URL) {
        let dataViewModel = DataViewModel()
        self.sensors = dataViewModel.getSensors(directoryUrl: directoryUrl)
        self.currentSensor = sensors[0]
        self.videos = []
        self.currentTime = sensors[0].data[0].timestamp
        self.sensorId = sensors[0].id
        self.timeWindow = timeWindow
        self.directoryUrl = directoryUrl
        self.annotations = [
            Annotation(timestamp: 0, type: "RecordingStart", content: ""),
            Annotation(timestamp: 33, type: "RecordingPause", content: ""),
            Annotation(timestamp: 34, type: "RecordingResume", content: ""),
            Annotation(timestamp: 37, type: "VideoAnnotationStart", content: ""),
            Annotation(timestamp: 62, type: "VideoAnnotationStop", content: ""),
            Annotation(timestamp: 68, type: "VideoAnnotationStart", content: ""),
            Annotation(timestamp: 83, type: "VideoAnnotationStop", content: ""),
            Annotation(timestamp: 100, type: "RecordingStop", content: "")
        ]
    }
}
