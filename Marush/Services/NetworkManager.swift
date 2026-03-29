import Foundation

class NetworkManager {
    
    static let shared = NetworkManager() // Singleton for global access
    
    // Private initializer to prevent instantiation
    private init() {}
    
    
    func constructURL(endpoint: String) -> URL? {
        let apiUrl = getApiUrl()
        return URL(string: "\(apiUrl)\(endpoint)")
    }

    
    // Perform the network request
    func performRequest<T: Decodable>(url: URL?, body: [String: Any]?, completion: @escaping (T?) -> Void) {
        guard let url = url else {
            print("Invalid URL")
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let api_token: String = "eyJzdWIYwnocYOAYndoc7qy3rn7ywiPOk6yJV_adQssw5bmFtZSI6IkpvaG4gRG9lIO879IG87tsigiwiaWF0IjoxNjA0ODI3MjAwfQ"
        request.setValue("\(api_token)", forHTTPHeaderField: "X-API-KEY")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
            request.httpBody = jsonData
            
            print("Request URL: \(url)")
            print("Request Body: \(String(data: jsonData, encoding: .utf8) ?? "")")
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    print("Error: \(error.localizedDescription) \(url)")
                    completion(nil)
                    return
                }

                guard let apiData = data else {
                    print("No data found \(url)")
                    completion(nil)
                    return
                }

                do {
                    if let responseString = String(data: apiData, encoding: .utf8) {
//                        print("Response Data Success \(url) ")
                        print("Response Data Success \(url) \(responseString)")
                    }
                    
                    // Use the generic type T for decoding
                    let result = try JSONDecoder().decode(T.self, from: apiData)
                    DispatchQueue.main.async {
                        completion(result) // Return the decoded object of type T
                    }
                } catch let DecodingError.keyNotFound(key, context) {
                    print("Missing key '\(key.stringValue)' in \(url)")
                    print("Debug Description: \(context.debugDescription)")
                    print("CodingPath: \(context.codingPath)")
                    completion(nil)
                } catch let DecodingError.typeMismatch(type, context) {
                    print("Type mismatch for type '\(type)' in \(url)")
                    print("Debug Description: \(context.debugDescription)")
                    print("CodingPath: \(context.codingPath)")
                    completion(nil)
                } catch let DecodingError.valueNotFound(value, context) {
                    print("Value '\(value)' not found in \(url)")
                    print("Debug Description: \(context.debugDescription)")
                    print("CodingPath: \(context.codingPath)")
                    completion(nil)
                } catch let DecodingError.dataCorrupted(context) {
                    print("Data corrupted in \(url)")
                    print("Debug Description: \(context.debugDescription)")
                    completion(nil)
                } catch {
                    print("Decoding error \(url): \(error.localizedDescription)")
                    completion(nil)
                }
            }.resume()
            
        } catch {
            print("JSON serialization error \(url): \(error.localizedDescription)")
            completion(nil)
        }
    }
}
