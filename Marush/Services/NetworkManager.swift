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
            
            // Every exit path must land on the main queue: SwiftUI state written from a
            // background thread does not reliably refresh the UI, which made failures
            // look like "nothing happened".
            func finish(_ value: T?) {
                DispatchQueue.main.async { completion(value) }
            }

            URLSession.shared.dataTask(with: request) { (data, response, error) in
                let status = (response as? HTTPURLResponse)?.statusCode ?? 0

                if let error = error {
                    print("❌ Network error \(url): \(error.localizedDescription)")
                    finish(nil)
                    return
                }

                guard let apiData = data else {
                    print("❌ No data \(url) [HTTP \(status)]")
                    finish(nil)
                    return
                }

                let raw = String(data: apiData, encoding: .utf8) ?? ""

                do {
                    let result = try JSONDecoder().decode(T.self, from: apiData)
                    print("✅ \(url) [HTTP \(status)]")
                    finish(result)
                } catch let DecodingError.keyNotFound(key, context) {
                    print("❌ Missing key '\(key.stringValue)' in \(url)")
                    print("   CodingPath: \(context.codingPath)")
                    print("   Response: \(raw)")
                    finish(nil)
                } catch let DecodingError.typeMismatch(type, context) {
                    print("❌ Type mismatch for '\(type)' in \(url)")
                    print("   \(context.debugDescription)")
                    print("   CodingPath: \(context.codingPath)")
                    print("   Response: \(raw)")
                    finish(nil)
                } catch let DecodingError.valueNotFound(value, context) {
                    print("❌ Value '\(value)' not found in \(url)")
                    print("   CodingPath: \(context.codingPath)")
                    print("   Response: \(raw)")
                    finish(nil)
                } catch let DecodingError.dataCorrupted(context) {
                    print("❌ Data corrupted in \(url): \(context.debugDescription)")
                    print("   Response: \(raw)")
                    finish(nil)
                } catch {
                    print("❌ Decoding error \(url): \(error.localizedDescription)")
                    print("   Response: \(raw)")
                    finish(nil)
                }
            }.resume()
            
        } catch {
            print("❌ JSON serialization error \(url): \(error.localizedDescription)")
            DispatchQueue.main.async { completion(nil) }
        }
    }
}
