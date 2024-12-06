//
//  VideoFrameView.swift
//  LoadManagement
//
//  Created by Ásmundur Óskar Ásmundsson on 8.11.2024.
//

import SwiftUI
import AVKit

struct VideoPlayerViewController: UIViewControllerRepresentable {
    var player: AVPlayer?

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.showsPlaybackControls = true // Show playback controls
        return playerViewController
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        uiViewController.player = player
    }
}

struct VideoFrameView: View {
    var segments: [VideoData]
    @Binding var currentTime: Double
    @State private var player: AVPlayer? = nil
    @State private var currentSegment: VideoData? = nil

    var body: some View {
        VStack {
            if let player = player {
                VideoPlayerViewController(player: player)
            } else {
                // Placeholder view
                Color.black
                    .aspectRatio(16/9, contentMode: .fit)
                    .overlay(
                        Text("No Video Available")
                            .foregroundColor(.white)
                            .font(.headline)
                    )
            }
        }
        .onChange(of: currentTime) { oldTime, newTime in
            updateVideoPlayer(for: newTime)
        }
    }

    private func updateVideoPlayer(for time: Double) {
        if let segment = segments.first(where: { ($0.endTime - $0.duration + $0.startTimeAdjustment) <= time && $0.endTime >= time }) {
            if currentSegment?.url != segment.url {
                let newPlayer = AVPlayer(url: segment.url)
                player = newPlayer
                currentSegment = segment
            }
            let segmentRelativeTime = time - (segment.endTime - segment.duration + segment.startTimeAdjustment)
            let cmTime = CMTime(seconds: segmentRelativeTime, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            player?.seek(to: cmTime, toleranceBefore: .zero, toleranceAfter: .zero)
        } else {
            // No video for the current time, clear player
            player = nil
            currentSegment = nil
        }
    }
}


#Preview {
    @Previewable @State var previewCurrentTime: Double = 10.0
    @Previewable @State var previewTimeWindow: Double = 10.0
    @Previewable @State var previewDataCategory: String = "Acc"
    @Previewable @State var previewSensorId: String = "1234567890"

    @Previewable @State var videoSegments = [
        VideoData(url: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!, startTime: 23, startTimeAdjustment: 0.0, endTime: 38, duration: 15),
        VideoData(url: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4")!, startTime: 69, startTimeAdjustment: 0.0, endTime: 84, duration: 15)
    ]
    VStack {
        VideoFrameView(
            segments: videoSegments,
            currentTime: $previewCurrentTime
        )
        CustomToolbar(
            currentTime: $previewCurrentTime,
            timeWindow: $previewTimeWindow,
            dataCategory: $previewDataCategory,
            sensorId: $previewSensorId,
            sensors: [],
            totalDataLength: 100,
            dataStartTime: 0,
            dataEndTime: 100,
            dataFrequency: 1,
            videos: $videoSegments
        )
    }
    
}

