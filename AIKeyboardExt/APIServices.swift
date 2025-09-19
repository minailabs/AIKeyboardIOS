import Foundation

struct GrammarCheckRequest: Codable {
    let text: String
}

struct GrammarCheckResponse: Codable {
    let status: String
    let input: String
    let output: String
}

struct ToneChangeRequest: Codable {
    let text: String
    let tone: String
}

typealias AskAIRequest = GrammarCheckRequest

enum APIError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingError(Error)
}

final class APIService {
    static let shared = APIService()
    private init() {}

    func checkGrammar(text: String) async -> Result<GrammarCheckResponse, APIError> {
        guard let url = URL(string: "https://kb-api.minailabs.io/grammar-check") else {
            return .failure(.invalidURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONEncoder().encode(GrammarCheckRequest(text: text))
        } catch {
            return .failure(.requestFailed(error))
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return .failure(.invalidResponse)
            }
            
            let decodedResponse = try JSONDecoder().decode(GrammarCheckResponse.self, from: data)
            return .success(decodedResponse)
        } catch {
            return .failure(.decodingError(error))
        }
    }
    
    func changeTone(text: String, tone: String) async -> Result<GrammarCheckResponse, APIError> {
        guard let url = URL(string: "https://kb-api.minailabs.io/tone-change") else {
            return .failure(.invalidURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(ToneChangeRequest(text: text, tone: tone))
        } catch {
            return .failure(.requestFailed(error))
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return .failure(.invalidResponse)
            }
            
            let decodedResponse = try JSONDecoder().decode(GrammarCheckResponse.self, from: data)
            return .success(decodedResponse)
        } catch {
            return .failure(.decodingError(error))
        }
    }
    
    func askAI(text: String) async -> Result<GrammarCheckResponse, APIError> {
        guard let url = URL(string: "https://kb-api.minailabs.io/ask-ai") else {
            return .failure(.invalidURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(AskAIRequest(text: text))
        } catch {
            return .failure(.requestFailed(error))
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return .failure(.invalidResponse)
            }
            
            let decodedResponse = try JSONDecoder().decode(GrammarCheckResponse.self, from: data)
            return .success(decodedResponse)
        } catch {
            return .failure(.decodingError(error))
        }
    }
}
