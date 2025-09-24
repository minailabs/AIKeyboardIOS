import Foundation
import SwiftUI

@MainActor
final class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var isSendingMessage: Bool = false
    
    private let apiService = APIService.shared
    
    init() {
        // You can add a welcome message here if you like
        messages.append(Message(content: .text("Hello! How can I help you today?"), isUserMessage: false))
    }
    
    func sendMessage(_ messageText: String) {
        // First, construct the history from the current state. This ensures we don't include
        // the new message or the indicator in the history being sent.
        var history = messages.compactMap { msg -> HistoryMessage? in
            // Only include messages that have text content (i.e., from user or model).
            guard case .text(let content) = msg.content else { return nil }
            let role = msg.isUserMessage ? "user" : "model"
            return HistoryMessage(role: role, content: content)
        }

        // Ensure the history sent to the API starts with a user turn.
        // This is a common requirement for chat APIs.
        if let firstMessage = history.first, firstMessage.role == "model" {
            history.removeFirst()
        }

        // Now, update the UI with the new message and indicator.
        let userMessage = Message(content: .text(messageText), isUserMessage: true)
        messages.append(userMessage)
        messages.append(Message(content: .indicator, isUserMessage: false))
        isSendingMessage = true
        
        Task {
            let result = await apiService.sendChatMessage(history: history, newMessage: messageText)
            
            // Remove the indicator from the UI
            _ = messages.popLast()
            isSendingMessage = false
            
            switch result {
            case .success(let response):
                let aiMessage = Message(content: .text(response.output), isUserMessage: false)
                messages.append(aiMessage)
            case .failure(let error):
                // Detailed error logging for debugging
                print("--- API Error ---")
                print("Error: \(error)")
                if case let APIError.decodingError(decodingError) = error {
                    print("Decoding Error Details: \(decodingError)")
                }
                // ---
                
                let errorMessage = Message(content: .error("Sorry, something went wrong. Please try again."), isUserMessage: false)
                messages.append(errorMessage)
            }
        }
    }
}
