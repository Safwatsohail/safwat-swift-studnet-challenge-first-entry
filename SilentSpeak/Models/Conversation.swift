import Foundation

struct ConversationMessage: Codable, Identifiable {
    let id: UUID
    let text: String
    let isFromDeafUser: Bool
    let timestamp: Date
    
    init(id: UUID = UUID(), text: String, isFromDeafUser: Bool, timestamp: Date = Date()) {
        self.id = id
        self.text = text
        self.isFromDeafUser = isFromDeafUser
        self.timestamp = timestamp
    }
}

struct Conversation: Codable, Identifiable {
    let id: UUID
    var title: String
    var messages: [ConversationMessage]
    let createdAt: Date
    var updatedAt: Date
    var isPinned: Bool
    
    init(id: UUID = UUID(), title: String = "New Conversation", messages: [ConversationMessage] = [], createdAt: Date = Date(), updatedAt: Date = Date(), isPinned: Bool = false) {
        self.id = id
        self.title = title
        self.messages = messages
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isPinned = isPinned
    }
    
    var lastMessagePreview: String {
        messages.last?.text ?? "No messages yet"
    }
    
    var formattedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: updatedAt, relativeTo: Date())
    }
    
    var messageCount: Int {
        messages.count
    }
}

struct SavedPhrase: Codable, Identifiable {
    let id: UUID
    let text: String
    let category: String
    let savedAt: Date
    
    init(id: UUID = UUID(), text: String, category: String = "General", savedAt: Date = Date()) {
        self.id = id
        self.text = text
        self.category = category
        self.savedAt = savedAt
    }
}
