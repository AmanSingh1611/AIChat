//
//  ChatModel.swift
//  AIChat
//
//  Created by Aman on 07/03/26.
//

import Foundation

struct ChatModel: Identifiable {
    
    let id: String
    let userId: String
    let avatarId: String
    let dateCreated: Date
    let dateModified: Date
    
    static var mock: ChatModel {
        mocks.first!
    }
    
    static var mocks: [ChatModel] {
        let now = Date()
        
        return [
            ChatModel(
                id: "mock_chat_1",
                userId: "user_1",
                avatarId: "avatar_1",
                dateCreated: now.addTimeInterval(days: -3, hours: -2),
                dateModified: now.addTimeInterval(days: -3, hours: -1, minutes: -20)
            ),
            
            ChatModel(
                id: "mock_chat_2",
                userId: "user_2",
                avatarId: "avatar_2",
                dateCreated: now.addTimeInterval(days: -2, hours: -5, minutes: -10),
                dateModified: now.addTimeInterval(days: -2, hours: -3)
            ),
            
            ChatModel(
                id: "mock_chat_3",
                userId: "user_3",
                avatarId: "avatar_3",
                dateCreated: now.addTimeInterval(days: -1, hours: -4, minutes: -30),
                dateModified: now.addTimeInterval(days: -1, hours: -2, minutes: -10)
            ),
            
            ChatModel(
                id: "mock_chat_4",
                userId: "user_4",
                avatarId: "avatar_4",
                dateCreated: now.addTimeInterval(hours: -6),
                dateModified: now.addTimeInterval(hours: -1, minutes: -15)
            )
        ]
    }
}
