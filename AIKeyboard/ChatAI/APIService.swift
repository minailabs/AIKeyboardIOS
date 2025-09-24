import Foundation

// MARK: - API Request/Response Models

struct ChatAIRequest: Codable {
    let history_messages: [HistoryMessage]
    let new_message: String
}

struct HistoryMessage: Codable {
    let role: String
    let content: String
}

struct APIResponse: Codable {
    let status: String
    let input: String
    let output: String
}

enum APIError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingError(Error)
}

// MARK: - APIService

final class APIService {
    
    static let shared = APIService()
    private let baseURL = "https://kb-api.minailabs.io"
    
    private init() {}
    
    func sendChatMessage(history: [HistoryMessage], newMessage: String) async -> Result<APIResponse, APIError> {
        guard let url = URL(string: "\(baseURL)/chat-ai") else {
            return .failure(.invalidURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = ChatAIRequest(history_messages: history, new_message: newMessage)
        
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            return .failure(.requestFailed(error))
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return .failure(.invalidResponse)
            }
            
            let decodedResponse = try JSONDecoder().decode(APIResponse.self, from: data)
            return .success(decodedResponse)
        } catch {
            return .failure(.decodingError(error))
        }
    }
}
