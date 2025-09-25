import Foundation

struct Conversation: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var createdAt: Date
    var messages: [HistoryMessage]

    init(id: UUID = UUID(), title: String, createdAt: Date = Date(), messages: [HistoryMessage]) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.messages = messages
    }
}

// Explicit Equatable conformance (synthesis fails due to non-Equatable members)
extension Conversation {
    static func == (lhs: Conversation, rhs: Conversation) -> Bool {
        return lhs.id == rhs.id
    }
}

final class ChatHistoryStore: ObservableObject {
    @Published private(set) var conversations: [Conversation] = []

    private let storageKey = "chat_history_store"

    init() {
        load()
    }

    // Create a new conversation and return its id
    @discardableResult
    func createNew(title: String = "New chat", messages: [HistoryMessage] = []) -> UUID {
        let convo = Conversation(title: title, messages: messages)
        conversations.insert(convo, at: 0)
        save()
        return convo.id
    }

    // Update an existing conversation
    func update(id: UUID, messages: [HistoryMessage], title: String? = nil) {
        guard let idx = conversations.firstIndex(where: { $0.id == id }) else { return }
        conversations[idx].messages = messages
        if let t = title { conversations[idx].title = t }
        save()
    }

    // Legacy helper left in place (not used by new code)
    func addOrUpdate(from history: [HistoryMessage]) {
        guard let firstUser = history.first(where: { $0.role == "user" }) else { return }
        let title = String(firstUser.content.prefix(50))
        let convo = Conversation(title: title, messages: history)
        conversations.insert(convo, at: 0)
        save()
    }

    func clearAll() {
        conversations.removeAll()
        save()
    }

    func save() {
        do {
            let data = try JSONEncoder().encode(conversations)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch { }
    }

    func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        if let decoded = try? JSONDecoder().decode([Conversation].self, from: data) {
            conversations = decoded
        }
    }
}
