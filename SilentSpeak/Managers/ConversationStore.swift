import Foundation
import SwiftUI

class ConversationStore: ObservableObject {
    @Published var conversations: [Conversation] = []
    @Published var savedPhrases: [SavedPhrase] = []
    
    private let conversationsKey = "saved_conversations"
    private let phrasesKey = "saved_phrases"
    
    init() {
        loadConversations()
        loadPhrases()
    }
    
    // MARK: - Conversations
    
    func loadConversations() {
        guard let data = UserDefaults.standard.data(forKey: conversationsKey),
              let decoded = try? JSONDecoder().decode([Conversation].self, from: data) else {
            return
        }
        conversations = decoded.sorted { $0.updatedAt > $1.updatedAt }
    }
    
    func saveConversations() {
        if let encoded = try? JSONEncoder().encode(conversations) {
            UserDefaults.standard.set(encoded, forKey: conversationsKey)
        }
    }
    
    func createConversation() -> Conversation {
        let conversation = Conversation()
        conversations.insert(conversation, at: 0)
        saveConversations()
        return conversation
    }
    
    func deleteConversation(_ conversation: Conversation) {
        conversations.removeAll { $0.id == conversation.id }
        saveConversations()
    }
    
    func deleteConversations(at offsets: IndexSet) {
        conversations.remove(atOffsets: offsets)
        saveConversations()
    }
    
    func addMessage(to conversationId: UUID, text: String, isFromDeafUser: Bool) {
        guard let index = conversations.firstIndex(where: { $0.id == conversationId }) else { return }
        let message = ConversationMessage(text: text, isFromDeafUser: isFromDeafUser)
        conversations[index].messages.append(message)
        conversations[index].updatedAt = Date()
        
        // Auto-generate title from first message
        if conversations[index].messages.count == 1 {
            let preview = String(text.prefix(30))
            conversations[index].title = preview + (text.count > 30 ? "..." : "")
        }
        
        saveConversations()
    }
    
    func togglePin(_ conversation: Conversation) {
        guard let index = conversations.firstIndex(where: { $0.id == conversation.id }) else { return }
        conversations[index].isPinned.toggle()
        saveConversations()
    }
    
    func clearAllConversations() {
        conversations.removeAll()
        saveConversations()
    }
    
    var pinnedConversations: [Conversation] {
        conversations.filter { $0.isPinned }
    }
    
    var unpinnedConversations: [Conversation] {
        conversations.filter { !$0.isPinned }
    }
    
    // MARK: - Phrases
    
    func loadPhrases() {
        guard let data = UserDefaults.standard.data(forKey: phrasesKey),
              let decoded = try? JSONDecoder().decode([SavedPhrase].self, from: data) else {
            // Seed with some default phrases
            savedPhrases = [
                SavedPhrase(text: "Hello, how are you?", category: "Greetings"),
                SavedPhrase(text: "Thank you very much", category: "Greetings"),
                SavedPhrase(text: "Can you help me?", category: "Requests"),
                SavedPhrase(text: "Where is the bathroom?", category: "Directions"),
                SavedPhrase(text: "I need water please", category: "Requests"),
                SavedPhrase(text: "Nice to meet you", category: "Greetings"),
                SavedPhrase(text: "How much does this cost?", category: "Shopping"),
                SavedPhrase(text: "I don't understand", category: "General"),
                SavedPhrase(text: "Please speak slowly", category: "General"),
                SavedPhrase(text: "What is your name?", category: "Greetings"),
            ]
            savePhrases()
            return
        }
        savedPhrases = decoded
    }
    
    func savePhrases() {
        if let encoded = try? JSONEncoder().encode(savedPhrases) {
            UserDefaults.standard.set(encoded, forKey: phrasesKey)
        }
    }
    
    func addPhrase(_ text: String, category: String = "General") {
        let phrase = SavedPhrase(text: text, category: category)
        savedPhrases.insert(phrase, at: 0)
        savePhrases()
    }
    
    func deletePhrase(_ phrase: SavedPhrase) {
        savedPhrases.removeAll { $0.id == phrase.id }
        savePhrases()
    }
    
    func deletePhrases(at offsets: IndexSet) {
        savedPhrases.remove(atOffsets: offsets)
        savePhrases()
    }
    
    var phraseCategories: [String] {
        Array(Set(savedPhrases.map { $0.category })).sorted()
    }
    
    func phrases(for category: String) -> [SavedPhrase] {
        savedPhrases.filter { $0.category == category }
    }
}
