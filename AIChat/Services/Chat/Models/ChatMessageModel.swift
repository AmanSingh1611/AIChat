//
//  ChatMessageModel.swift
//  AIChat
//
//  Created by Aman on 07/03/26.
//
import Foundation

struct ChatMessageModel: Identifiable, Codable {
    
    let id: String
    let chatId: String
    let authorId: String?
    let content: AIChatModel?
    let seenByIds: [String]?
    let dateCreated: Date?
    
    init(
        id: String,
        chatId: String,
        authorId: String? = nil,
        content: AIChatModel? = nil,
        seenByIds: [String]? = nil,
        dateCreated: Date? = nil
    ) {
        self.id = id
        self.chatId = chatId
        self.authorId = authorId
        self.content = content
        self.seenByIds = seenByIds
        self.dateCreated = dateCreated
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case chatId = "chat_id"
        case authorId = "author_id"
        case content
        case seenByIds = "seen_by_ids"
        case dateCreated = "date_created"
    }
    
    static var mock: ChatMessageModel {
        mocks.first!
    }
    
    func hasBeenSeenBy(userId: String) -> Bool {
        guard let seenByIds else { return false }
        
        return seenByIds.contains(userId)
    }
    
    static func newUserMessage(chatId: String, userId: String, message: AIChatModel) -> Self {
        ChatMessageModel(
            id: UUID().uuidString,
            chatId: chatId,
            authorId: userId,
            content: message,
            seenByIds: [userId],
            dateCreated: .now
        )
    }
    
    static func newAIMessage(chatId: String, avatarId: String, message: AIChatModel) -> Self {
        ChatMessageModel(
            id: UUID().uuidString,
            chatId: chatId,
            authorId: avatarId,
            content: message,
            seenByIds: [],
            dateCreated: .now
        )
    }
    
    static var mocks: [ChatMessageModel] {
        let now = Date()
        
        return [
            ChatMessageModel(
                id: "msg_1",
                chatId: "1",
                authorId: UserAuthInfo.mock().uid,
                content: AIChatModel(role: .user, content: "Hey, how are you?"),
                seenByIds: ["user_2"],
                dateCreated: now.addTimeInterval(minutes: -50)
            ),
            
            ChatMessageModel(
                id: "msg_2",
                chatId: "1",
                authorId: AvatarModel.mock.avatarId,
                content: AIChatModel(role: .assistant, content: "I'm good! What about you?"),
                seenByIds: ["user_1"],
                dateCreated: now.addTimeInterval(minutes: -40)
            ),
            
            ChatMessageModel(
                id: "msg_3",
                chatId: "1",
                authorId: UserAuthInfo.mock().uid,
                content: AIChatModel(role: .user, content: "Doing great. Working on the new feature."),
                seenByIds: ["user_2"],
                dateCreated: now.addTimeInterval(minutes: -25)
            ),
            
            ChatMessageModel(
                id: "msg_4",
                chatId: "1",
                authorId: AvatarModel.mock.avatarId,
                content: AIChatModel(role: .assistant, content: "Nice! Let me know if you need help."),
                seenByIds: ["user_1"],
                dateCreated: now.addTimeInterval(minutes: -10)
            )
        ]
    }
}
