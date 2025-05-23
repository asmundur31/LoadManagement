//
//  SplitscreenView.swift
//  LoadManagement
//
//  Created by Ásmundur Óskar Ásmundsson on 6.11.2024.
//

import SwiftUI

struct SplitscreenView: View {
    @Environment(RecordingViewModel.self) var recordingViewModel: RecordingViewModel

    @State private var currentTime: Double
    @State private var timeWindow: Double
    @State private var dataCategory: String
    @State private var currentSensor: Int

    // State for adjusting the split view
    @State private var videoWidthRatio: CGFloat = 0.5
    @State private var videoHeightRatio: CGFloat = 0.5

    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                if geometry.size.width > geometry.size.height {
                    // Landscape - side by side layout
                    HStack(spacing: 0) {
                        // Video frame takes up a fraction of the width based on videoWidthRatio
                        VideoFrameView(currentTime: $currentTime)
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
                        GraphView(currentTime: $currentTime, timeWindow: $timeWindow, currentSensor: $currentSensor, dataCategory: $dataCategory)
                            .frame(width: geometry.size.width * (1 - videoWidthRatio))
                            .background(Color.white) // Add background color for visual separation
                    }
                } else {
                    // Portrait - stacked layout
                    VStack(spacing: 0) {
                        VideoFrameView(currentTime: $currentTime)
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
                        
                        GraphView(currentTime: $currentTime, timeWindow: $timeWindow, currentSensor: $currentSensor, dataCategory: $dataCategory)
                            .frame(height: geometry.size.height * (1-videoHeightRatio))
                            .background(Color.white) // Add background color for visual separation
                    }
                }
            }
            
            CustomToolbar(
                currentTime: $currentTime,
                currentTimeWindow: $timeWindow,
                currentDataCategory: $dataCategory,
                currentSensor: $currentSensor
            )
        }
        .navigationTitle("Splitscreen View")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let firstTimestamp = recordingViewModel.recording?.sensors.first?.recordingData.getTimeStamp().first {
                self.currentTime = firstTimestamp
            }
        }
    }
    
    init(timeWindow: Double) {
        self.timeWindow = timeWindow
        self.dataCategory = "Acc"
        self.currentSensor = 0
        self.currentTime = 0.0
    }
}
