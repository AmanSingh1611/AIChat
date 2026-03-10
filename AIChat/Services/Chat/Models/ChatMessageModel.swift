//
//  ChatMessageModel.swift
//  AIChat
//
//  Created by Aman on 07/03/26.
//
import Foundation

struct ChatMessageModel {
    
    let id: String
    let chatId: String
    let authorId: String?
    let content: String?
    let seenByIds: [String]?
    let dateCreated: Date?
    
    init(
        id: String,
        chatId: String,
        authorId: String? = nil,
        content: String? = nil,
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
    
    static var mock: ChatMessageModel {
        mocks.first!
    }
    
    func hasBeenSeenBy(userId: String) -> Bool {
        guard let seenByIds else { return false }
        
        return seenByIds.contains(userId)
    }
    
    static var mocks: [ChatMessageModel] {
        let now = Date()
        
        return [
            ChatMessageModel(
                id: "msg_1",
                chatId: "1",
                authorId: "user_1",
                content: "Hey, how are you?",
                seenByIds: ["user_2"],
                dateCreated: now.addTimeInterval(minutes: -50)
            ),
            
            ChatMessageModel(
                id: "msg_2",
                chatId: "1",
                authorId: "user_2",
                content: "I'm good! What about you?",
                seenByIds: ["user_1"],
                dateCreated: now.addTimeInterval(minutes: -40)
            ),
            
            ChatMessageModel(
                id: "msg_3",
                chatId: "1",
                authorId: "user_1",
                content: "Doing great. Working on the new feature.",
                seenByIds: ["user_2"],
                dateCreated: now.addTimeInterval(minutes: -25)
            ),
            
            ChatMessageModel(
                id: "msg_4",
                chatId: "1",
                authorId: "user_2",
                content: "Nice! Let me know if you need help.",
                seenByIds: ["user_1"],
                dateCreated: now.addTimeInterval(minutes: -10)
            )
        ]
    }
}
