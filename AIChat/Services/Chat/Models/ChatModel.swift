//
//  ChatModel.swift
//  AIChat
//
//  Created by Aman on 07/03/26.
//

import Foundation
import IdentifiableByString

struct ChatModel: Identifiable, Codable, StringIdentifiable, Hashable {
    
    let id: String
    let userId: String
    let avatarId: String
    let dateCreated: Date
    let dateModified: Date
    
    static var mock: ChatModel {
        mocks.first!
    }
    
    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "chat_\(CodingKeys.id.rawValue)": id,
            "chat_\(CodingKeys.userId.rawValue)": userId,
            "chat_\(CodingKeys.avatarId.rawValue)": avatarId,
            "chat_\(CodingKeys.dateCreated.rawValue)": dateCreated,
            "chat_\(CodingKeys.dateModified.rawValue)": dateModified
        ]
        return dict.compactMapValues({ $0 })
    }
    
    static func chatId(userId: String, avatarId: String) -> String {
        return "\(userId)_\(avatarId)"
    }
    
    static func new(userId: String, avatarId: String) -> Self {
        ChatModel(
            id: chatId(userId: userId, avatarId: avatarId),
            userId: userId,
            avatarId: avatarId,
            dateCreated: .now,
            dateModified: .now
        )
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case avatarId = "avatar_id"
        case dateCreated = "date_created"
        case dateModified = "date_modified"
    }
    
    static var mocks: [Self] {
        let now = Date()
        let userId = UserAuthInfo.mock().uid
        let avatars = AvatarModel.mocks
        
        func randomAvatarId() -> String {
            avatars.randomElement()?.avatarId ?? "avatar_fallback"
        }
        
        return [
            ChatModel(
                id: "mock_chat_1",
                userId: userId,
                avatarId: randomAvatarId(),
                dateCreated: now.addTimeInterval(days: -3, hours: -2),
                dateModified: now.addTimeInterval(days: -3, hours: -1, minutes: -20)
            ),
            
            ChatModel(
                id: "mock_chat_2",
                userId: userId,
                avatarId: randomAvatarId(),
                dateCreated: now.addTimeInterval(days: -2, hours: -5, minutes: -10),
                dateModified: now.addTimeInterval(days: -2, hours: -3)
            ),
            
            ChatModel(
                id: "mock_chat_3",
                userId: userId,
                avatarId: randomAvatarId(),
                dateCreated: now.addTimeInterval(days: -1, hours: -4, minutes: -30),
                dateModified: now.addTimeInterval(days: -1, hours: -2, minutes: -10)
            ),
            
            ChatModel(
                id: "mock_chat_4",
                userId: userId,
                avatarId: randomAvatarId(),
                dateCreated: now.addTimeInterval(hours: -6),
                dateModified: now.addTimeInterval(hours: -1, minutes: -15)
            )
        ]
    }
}
