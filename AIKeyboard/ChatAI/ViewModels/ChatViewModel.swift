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
    
    func loadConversation(_ convo: Conversation) {
        messages = convo.messages.map { msg in
            Message(content: .text(msg.content), isUserMessage: (msg.role == "user"))
        }
    }
    
    func exportHistory() -> [HistoryMessage] {
        messages.compactMap { msg -> HistoryMessage? in
            guard case .text(let content) = msg.content else { return nil }
            return HistoryMessage(role: msg.isUserMessage ? "user" : "model", content: content)
        }
    }
    
    func sendMessage(_ messageText: String) {
        var history = exportHistory()
        if let firstMessage = history.first, firstMessage.role == "model" {
            history.removeFirst()
        }
        let userMessage = Message(content: .text(messageText), isUserMessage: true)
        messages.append(userMessage)
        messages.append(Message(content: .indicator, isUserMessage: false))
        isSendingMessage = true
        
        Task {
            let result = await apiService.sendChatMessage(history: history, newMessage: messageText)
            _ = messages.popLast()
            isSendingMessage = false
            
            switch result {
            case .success(let response):
                let aiMessage = Message(content: .text(response.output), isUserMessage: false)
                messages.append(aiMessage)
            case .failure(let error):
                print("--- API Error ---")
                print("Error: \(error)")
                if case let APIError.decodingError(decodingError) = error {
                    print("Decoding Error Details: \(decodingError)")
                }
                let errorMessage = Message(content: .error("Sorry, something went wrong. Please try again."), isUserMessage: false)
                messages.append(errorMessage)
            }
        }
    }
}
