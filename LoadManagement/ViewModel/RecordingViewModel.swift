//
//  RecordingViewModel.swift
//  LoadManagement
//
//  Created by Ásmundur Óskar Ásmundsson on 17.12.2024.
//

import Foundation
import AVFoundation

@Observable
class RecordingViewModel {
    var recordings: [RecordingWithUser] = []
    var recording: Recording?
    
    func getRecordings(user: User) {
        APIService.shared.fetchRecordings(user: user) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let recordings):
                    self.recordings = recordings
                case .failure(let error):
                    print("Error fetching recordings: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func getRecording(recording_id: Int) {
        APIService.shared.fetchRecording(recording_id: recording_id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let recordingWithZip):
                    // Successfully fetched recording download details
                    self.loadDataToMemory(recordingWithZip: recordingWithZip) { result in
                        switch result {
                        case .success(let directoryUrl):
                            // Now data is in the app data
                            Task {
                                self.recording = await self.getRecordingFromDirectory(at: directoryUrl)
                            }
                        case .failure(let error):
                            print("Failed to load data to memory: \(error.localizedDescription)")
                        }
                    }
                case .failure(let error):
                    print("Error fetching recordings: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func loadDataToMemory(recordingWithZip: RecordingWithZip, completion: @escaping (Result<URL, Error>) -> Void) {
        APIService.shared.fetchAndExtractZipFile(recordingWithZip: recordingWithZip) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let extractedDirectoryURL):
                    do {
                        try self.printDirectoryContentsRecursively(at: extractedDirectoryURL)
                    } catch {
                        print("Failed to list contents of extracted directory: \(error.localizedDescription)")
                        completion(.failure(error))
                        return
                    }
                    completion(.success(extractedDirectoryURL))
                case .failure(let error):
                    print("Failed to fetch and extract ZIP file: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }
    }
    
    func printDirectoryContentsRecursively(at url: URL, indentLevel: Int = 0) throws {
        let fileManager = FileManager.default
        let contents = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
        
        let indent = String(repeating: "  ", count: indentLevel)
        for item in contents {
            print("\(indent)- \(item.lastPathComponent)")
            var isDirectory: ObjCBool = false
            if fileManager.fileExists(atPath: item.path, isDirectory: &isDirectory), isDirectory.boolValue {
                // Recursive call for subdirectory
                try printDirectoryContentsRecursively(at: item, indentLevel: indentLevel + 1)
            }
        }
    }
    
    func getRecordingFromDirectory(at directoryUrl: URL) async -> Recording {
        // Parse annotations from the directory
        let parser = Parser()
        
        // Determain the sensor type
        let sensorType = DetermainSensor().determineSensorType(from: directoryUrl)
        print(sensorType)
        
        // Fetch and process all video files in the directory
        let videoFiles = getVideoFiles(from: directoryUrl)
        
        // Create VideoData objects from video files, sorted by name
        let videoData = await createVideoData(from: videoFiles)
        
        // Parse sensors based on the determined sensor type
        var sensors: [any Sensor] = []

        switch sensorType {
        case "MySensor":
            sensors = parser.parseSensors(from: directoryUrl, sensorType: MySensor.self)
        case "MariahSensor":
            sensors = parser.parseSensors(from: directoryUrl, sensorType: MariahSensor.self)
        default:
            break
        }
        // Create and return the Recording object
        let recording = Recording(videos: videoData, sensors: sensors)
        return recording
    }
    
    // Helper function to fetch all video files from the directory
    func getVideoFiles(from directoryUrl: URL) -> [URL] {
        let fileManager = FileManager.default
        do {
            let allFiles = try fileManager.contentsOfDirectory(at: directoryUrl, includingPropertiesForKeys: nil)
            // Filter out video files, assuming they have specific extensions like .mp4, .mov, etc.
            return allFiles.filter { $0.pathExtension.lowercased() == "mp4" || $0.pathExtension.lowercased() == "mov" }
        } catch {
            print("Error fetching files from directory: \(error)")
            return []
        }
    }
    
    // Helper function to create VideoData objects from video files, sorted by name
    func createVideoData(from videoFiles: [URL]) async -> [VideoData] {
        var videoData: [VideoData] = []
        
        // Sort the video files by name to ensure chronological order
        let sortedVideoFiles = videoFiles.sorted { $0.lastPathComponent < $1.lastPathComponent }
        
        for (_, videoUrl) in sortedVideoFiles.enumerated() {
            let videoDuration = await getVideoDuration(from: videoUrl)
            // Create a VideoData object
            let video = VideoData(url: videoUrl,
                                  startTime: 0.0,
                                  startTimeAdjustment: 0.0,
                                  playbackSpeed: 1.0,
                                  duration: videoDuration)
            videoData.append(video)
        }
        
        return videoData
    }

    // Helper function to get video duration from the metadata
    func getVideoDuration(from videoUrl: URL) async -> Double {
        let asset = AVURLAsset(url: videoUrl)
        
        do {
            let duration = try await asset.load(.duration)
            print(CMTimeGetSeconds(duration))
            return CMTimeGetSeconds(duration)
        } catch {
            print("Error loading video duration: \(error.localizedDescription)")
            return 0.0
        }
    }

    func getVideoStartTimestamp(from url: URL) async -> Date? {
        let asset = AVURLAsset(url: url)
        
        // Load metadata asynchronously
        do {
            let metadataItems = try await asset.load(.metadata)
            
            // Find creation date metadata
            if let metadataItem = metadataItems.first(where: { $0.identifier == AVMetadataIdentifier.quickTimeMetadataCreationDate }),
               let dateString = try? await metadataItem.load(.stringValue) {
                
                // Convert the ISO 8601 string to a Date object
                let formatter = ISO8601DateFormatter()
                return formatter.date(from: dateString)
            }
        } catch {
            print("Error loading video start timestamp: \(error.localizedDescription)")
            return nil
        }
        
        return nil
    }
    
    func deleteRecording(recording_id: Int) {
        // TODO: Delete recording from memory at /<user_id>/<recording_name>/Data
        APIService.shared.deleteRecording(recording_id: recording_id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("Recording deleted")
                case .failure(let error):
                    print("Failed to delete recording: \(error.localizedDescription)")
                }
            }
        }
    }
}
