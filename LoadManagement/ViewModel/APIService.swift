//
//  APIService.swift
//  LoadManagement
//
//  Created by Ásmundur Óskar Ásmundsson on 3.12.2024.
//

import Foundation

class APIService {
    static let shared = APIService()
    private let baseURL = "http://130.229.169.245:8000" // The IP address of my computer within my local network 

    private init() {}

    // Fetch all users
    func fetchUsers(completion: @escaping (Result<[User], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/users") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
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
        guard let url = URL(string: "\(baseURL)/users") else { return }
        
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
        guard let url = URL(string: "\(baseURL)/users/\(userId)") else { return }
        
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
        guard let url = URL(string: "\(baseURL)/upload/\(userId)") else { return }
        
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
        if let fileData = try? Data(contentsOf: zipURL) {
            body.append(fileData)
        }
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Failed to upload file: \(error)")
                return
            }
            if let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) {
                print("File uploaded successfully")
                completion(.success(()))
            } else {
                print("Failed with response.")
            }
        }.resume()
    }
}
