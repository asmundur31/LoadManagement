//
//  DetermainSensor.swift
//  LoadManagement
//
//  Created by Ásmundur Óskar Ásmundsson on 27.1.2025.
//

import Foundation
class DetermainSensor {
    func determineSensorType(from directoryUrl: URL) -> String {
        let fileManager = FileManager.default
        do {
            // Fetch all files in the directory
            let files = try fileManager.contentsOfDirectory(at: directoryUrl, includingPropertiesForKeys: nil)
            // Filter JSON files and exclude Annotation file if needed
            let jsonFiles = files.filter { $0.pathExtension == "json" && !$0.lastPathComponent.contains("Annotation") }
            
            // Check if there are any JSON files
            guard let firstFile = jsonFiles.first else {
                print("Returned 'Unknown Sensor'")
                return "Unknown Sensor"
            }
            
            // Read the first JSON file and try to decode it as a dictionary
            let data = try Data(contentsOf: firstFile)
            
            // Try to decode the file as a dictionary
            if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                // Check if 'recording_data' exists in the JSON object
                if let recordingData = jsonObject["recording_data"] as? [String: Any] {
                    // Now check if the necessary keys are present in the 'recording_data' dictionary
                    if let _ = recordingData["magnx"],
                       let _ = recordingData["magny"],
                       let _ = recordingData["magnz"] {
                        return "MySensor"
                    }
                    
                    if let _ = recordingData["hr"] {
                        return "MariahSensor"
                    }
                    print("No known sensor type found")
                }
            }
        } catch {
            print("Error reading directory or file: \(error)")
        }
        return "Unknown Sensor"
    }
}
