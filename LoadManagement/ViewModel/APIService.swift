//
//  APIService.swift
//  LoadManagement
//
//  Created by Ásmundur Óskar Ásmundsson on 3.12.2024.
//

import Foundation

class APIService {
    static let shared = APIService()
    //private let baseURL = "http://130.229.161.141:8000/" // The IP address of my computer within eduroam
    private let baseURL = "http://192.168.0.206:8000/" // The IP address of my computer within my local network
    //private let baseURL = "https://loadmanagement.vm-app.cloud.cbh.kth.se/" // The production url

    private init() {}

    // Fetch all users
    func fetchUsers(completion: @escaping (Result<[User], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)users/") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                return
            }

            // Check for redirect status codes (3xx)
            if (300...399).contains(httpResponse.statusCode) {
                print("Redirected to: \(httpResponse.allHeaderFields["Location"] ?? "No location header")")
            }
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else { return }
            do {
                let users = try JSONDecoder().decode([User].self, from: data)
                completion(.success(users))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    // Add a new user
    func addUser(userName: String, completion: @escaping (Result<User, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)users/") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["user_name": userName]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else { return }
            do {
                let newUser = try JSONDecoder().decode(User.self, from: data)
                completion(.success(newUser))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    // Update user name
    func updateUserName(userId: Int, newUserName: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)users/\(userId)/") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["user_name": newUserName]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }.resume()
    }
    
    // Upload recording
    func uploadRecording(zipURL: URL, userId: Int, recordingName: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)upload/\(userId)/") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Create multipart body
        var body = Data()
        
        // Append recording name
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"recording_name\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(recordingName)\r\n".data(using: .utf8)!)
        
        // Append zip file
        let filename = zipURL.lastPathComponent
        let mimeType = "application/zip"
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        
        do {
            let fileData = try Data(contentsOf: zipURL)
            body.append(fileData)
        } catch {
            completion(.failure(UploadError.fileReadError))
            return
        }
        
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, response, error in
            // Handle network errors
            if let error = error {
                completion(.failure(error))
                return
            }
            // Handle HTTP response
            guard let response = response as? HTTPURLResponse, let _ = data else {
                completion(.failure(UploadError.unknownError))
                return
            }
            switch response.statusCode {
            case 200...299:
                print("File uploaded successfully")
                completion(.success(()))
            case 404:
                completion(.failure(UploadError.userNotFound))
            case 409:
                // Assuming 409 Conflict indicates "recording name already taken"
                completion(.failure(UploadError.recordingNameTaken))
            default:
                // Handle other server errors
                print("Server error: \(response.statusCode)")
                completion(.failure(UploadError.serverError(statusCode: response.statusCode)))
            }
        }.resume()
    }
    
    // Fetch all recordings by user
    func fetchRecordings(user: User, completion: @escaping (Result<[RecordingWithUser], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)users/\(user.id)/recordings/") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else { return }
            do {
                let recordings = try JSONDecoder().decode([RecordingWithUser].self, from: data)
                completion(.success(recordings))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // Fetch recording by id
    func fetchRecording(recording_id: Int, completion: @escaping (Result<RecordingWithZip, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)recordings/\(recording_id)/") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else { return }
            do {
                let recording = try JSONDecoder().decode(RecordingWithZip.self, from: data)
                completion(.success(recording))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // Fetch zip file by url
    func fetchAndExtractZipFile(recordingWithZip: RecordingWithZip, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)\(recordingWithZip.zip_url)/") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        // Download the ZIP file
        URLSession.shared.downloadTask(with: url) { tempLocalURL, response, error in
            // Handle errors
            if let error = error {
                completion(.failure(error))
                return
            }
            // Validate HTTP response
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                let error = NSError(domain: "Invalid Response", code: httpResponse.statusCode, userInfo: nil)
                completion(.failure(error))
                return
            }
            // Ensure the file was downloaded
            guard let tempLocalURL = tempLocalURL else {
                completion(.failure(NSError(domain: "Download failed", code: 0, userInfo: nil)))
                return
            }
            do {
                // Define the target directory
                let documentsDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                let dataDirectory = documentsDirectory
                    .appendingPathComponent("\(recordingWithZip.recording.user_id)")
                    .appendingPathComponent(recordingWithZip.recording.recording_name)
                    .appendingPathComponent("Data")
                
                // Create the target directory if it doesn't exist
                try FileManager.default.createDirectory(at: dataDirectory, withIntermediateDirectories: true)
                
                // Remove all existing files in the Data directory
                let fileManager = FileManager.default
                let contents = try fileManager.contentsOfDirectory(at: dataDirectory, includingPropertiesForKeys: nil)
                for file in contents {
                    try fileManager.removeItem(at: file)
                }
                
                // Extract the ZIP file to the data directory
                try FileManager.default.unzipItem(at: tempLocalURL, to: dataDirectory)
                
                // Clean up the temporary file
                try FileManager.default.removeItem(at: tempLocalURL)
                
                // Return the extraction directory URL
                completion(.success(dataDirectory))
            } catch {
                // Cleanup and handle errors
                completion(.failure(error))
            }
        }.resume()
    }
    
    func deleteRecording(recording_id: Int, completion: @escaping (Result<Void, Error>) -> Void ) {
        guard let url = URL(string: "\(baseURL)recordings/\(recording_id)/") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            // Handle network errors
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Check for HTTP response and status code
            if let httpResponse = response as? HTTPURLResponse {
                if (200...299).contains(httpResponse.statusCode) {
                    completion(.success(())) // Success if the status code is 2xx
                } else {
                    // Handle non-2xx responses
                    let error = NSError(domain: "API Error", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to delete recording. HTTP Status Code: \(httpResponse.statusCode)"])
                    completion(.failure(error))
                }
            } else {
                // Handle unexpected response types
                let error = NSError(domain: "Unexpected Response", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to delete recording. Unexpected response from server."])
                completion(.failure(error))
            }
        }.resume()
    }
}
