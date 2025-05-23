//
//  RecordingView.swift
//  LoadManagement
//
//  Created by Ásmundur Óskar Ásmundsson on 17.12.2024.
//

import SwiftUI

struct RecordingView: View {
    @State private var recordingViewModel = RecordingViewModel()
    var recording_id: Int
    
    var body: some View {
        VStack(spacing: 20) {
            if recordingViewModel.recording == nil {
                Text("Fetching recording...")
                    .font(.headline)
                ProgressView()
            } else {
                // Display Recording Name
                Text("Recording Name: \(recordingViewModel.recording!.sensors.first?.recordingInfo.recordingName ?? "Fetching name...")")
                    .font(.system(size: 34, weight: .bold)) // Bigger and bold
                    .padding(.top, 30)

                Text("Nr of sensors: \(recordingViewModel.recording!.sensors.count)")
                    .font(.system(size: 30)) // Larger subheadline

                Text("Nr of videos: \(recordingViewModel.recording!.videos.count)")
                    .font(.system(size: 30))

                if let jumpCount = recordingViewModel.recording?.sensors.first?.recordingInfo.jumpCount {
                    Text("Nr of jumps: \(jumpCount)")
                        .font(.system(size: 30))
                } else {
                    Text("Fetching jump count...")
                        .font(.system(size: 30))
                }

            }
            
            Spacer()
            // Button to view the data
            if (recordingViewModel.recording != nil) {
                CustomButtonWithDestination(title: "View Data", color: Color.blue, destination: SplitscreenView(timeWindow: 10.0).environment( recordingViewModel))
            } else {
                Text("Data is being loaded to memory...")
            }
        }
        .padding()
        .onAppear {
            recordingViewModel.getRecording(recording_id: recording_id)
        }
    }
}

#Preview {
    NavigationStack {
        RecordingView(recording_id: 116)
    }
}
