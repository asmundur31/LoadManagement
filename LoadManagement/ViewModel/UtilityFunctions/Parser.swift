//
//  Parser.swift
//  LoadManagement
//
//  Created by Ásmundur Óskar Ásmundsson on 27.1.2025.
//
import Foundation

class Parser {
    func parseAnnotations(from directory: URL) -> Annotation? {
        do {
            // Fetch all files in the directory
            let annotationFiles = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
                .filter { $0.lastPathComponent.starts(with: "Annotation") && $0.pathExtension == "json" }
            
            // Check if no annotation file is found
            if annotationFiles.isEmpty {
                print("Warning: No annotation file found in directory \(directory.path)")
                return nil
            }
            // Ensure there is exactly one annotation file
            guard annotationFiles.count == 1 else {
                print("Error: Expected exactly one annotation file, but found \(annotationFiles.count)")
                return nil
            }
            
            // Load and decode the annotation file
            let data = try Data(contentsOf: annotationFiles.first!)
            let annotation = try JSONDecoder().decode(Annotation.self, from: data)
            
            return annotation
        } catch {
            print("Error parsing annotation: \(error)")
            return nil
        }
    }
    
    func parseSensors<T: Sensor>(from directory: URL, sensorType: T.Type) -> [T] {
        do {
            // Fetch all JSON files in the directory excluding Annotation files
            let jsonFiles = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
                .filter { $0.pathExtension == "json" && !$0.lastPathComponent.starts(with: "Annotation") }
            
            var sensors: [T] = []
            
            // Loop through each JSON file found
            for file in jsonFiles {                
                // Read the file data
                if let data = try? Data(contentsOf: file) {
                    do {
                        // Attempt to decode the sensor from the data
                        let sensor = try JSONDecoder().decode(T.self, from: data)
                        sensors.append(sensor)
                    } catch {
                        // If decoding fails, print the error
                        print("Failed to decode \(file): \(error)")
                    }
                } else {
                    print("Failed to read data from file: \(file)")
                }
            }
            
            return sensors
        } catch {
            print("Error reading directory or files: \(error)")
            return []
        }
    }
}
