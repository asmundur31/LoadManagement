//
//  SettingsView.swift
//  LoadManagement
//
//  Created by Ásmundur Óskar Ásmundsson on 27.1.2025.
//

import SwiftUI

struct SettingsView: View {
    @Environment(RecordingViewModel.self) var recordingViewModel: RecordingViewModel

    @Binding var currentTime: Double
    @Binding var timeWindow: Double
    @Binding var showSettings: Bool

    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    Text("Settings")
                        .font(.title)
                        .padding()

                    // Window Size Adjustment
                    windowSizeSlider
                    videoStartTimeAdjustments

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

    private var windowSizeSlider: some View {
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
    }

    private var videoStartTimeAdjustments: some View {
        ForEach(recordingViewModel.recording!.videos.indices, id: \.self) { index in
            VideoAdjustmentView(currentTime: $currentTime, index: index)
        }
    }
}

struct VideoAdjustmentView: View {
    @Environment(RecordingViewModel.self) var recordingViewModel: RecordingViewModel
    
    @Binding var currentTime: Double
    let speeds: [Double] = [0.25, 0.5, 1.0, 2.0, 4.0]
    var index: Int

    var body: some View {
        @Bindable var recordingViewModel = recordingViewModel
        VStack {
            HStack {
                Text("Video \(index+1)")
                    .font(.largeTitle)
                    .bold()
                Spacer()
            }
            .padding()
            HStack {
                ForEach(speeds, id: \.self) { speed in
                    Button(action: {
                        recordingViewModel.recording?.videos[index].playbackSpeed = speed
                    }) {
                        Text(String(format: "%.2fx",speed))
                            .padding()
                            .background(recordingViewModel.recording?.videos[index].playbackSpeed == speed ? Color.blue.opacity(0.7) : Color.gray.opacity(0.2))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
            CustomButton(title: "Set start time to current time", color: Color.blue, action: {
                recordingViewModel.recording?.videos[index].startTime = currentTime
            })
            HStack {
                Text("Start time adjustment:")
                Slider(
                   value: Binding(
                    get: { recordingViewModel.recording?.videos[index].startTimeAdjustment ?? 0.0 },
                       set: { newValue in
                           recordingViewModel.recording?.videos[index].startTimeAdjustment = newValue
                       }
                   ),
                   in: (recordingViewModel.recording?.videos[index].startTimeAdjustment ?? 0)-10...(recordingViewModel.recording?.videos[index].startTimeAdjustment ?? 0)+10,
                   step: 0.1
               )
               .padding()

                Text(String(format: "%.2f", recordingViewModel.recording?.videos[index].startTimeAdjustment ?? 0.0))
            }
            
            HStack {
                Button(action: {
                    recordingViewModel.recording?.videos[index].startTimeAdjustment -= 1
                }) {
                    Text("<")
                        .font(.title)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
                Button(action: {
                    recordingViewModel.recording?.videos[index].startTimeAdjustment -= 0.01
                }) {
                    Text("-")
                        .font(.title)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }

                Text(String(format: "%.2f", recordingViewModel.recording?.videos[index].startTimeAdjustment ?? 0.0))
                    .font(.title)
                    .padding(.horizontal, 20)

                Button(action: {
                    recordingViewModel.recording?.videos[index].startTimeAdjustment += 0.01
                }) {
                    Text("+")
                        .font(.title)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
                Button(action: {
                    recordingViewModel.recording?.videos[index].startTimeAdjustment += 1
                }) {
                    Text(">")
                        .font(.title)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var previewTimeWindow: Double = 10.0
    @Previewable @State var previewCurrentTime: Double = 0.0
    @Previewable @State var previewShowSettings: Bool = true
    
    SettingsView(
        currentTime: $previewCurrentTime, timeWindow: $previewTimeWindow,
        showSettings: $previewShowSettings
    )
}
