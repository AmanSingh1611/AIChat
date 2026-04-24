//
//  ChatService.swift
//  AIChat
//
//  Created by Aman on 24/04/26.
//
import SwiftUI

protocol ChatService: Sendable {
    func createNewChat(chat: ChatModel) async throws
    func addChatMessage(chatId: String, message: ChatMessageModel) async throws
}

struct MockChatService: ChatService {
    func addChatMessage(chatId: String, message: ChatMessageModel) async throws {
        
    }
        
    func createNewChat(chat: ChatModel) async throws {
        
    }
}

import FirebaseFirestore
import SwiftfulFirestore

struct FirebaseChatService: ChatService {
    private var collection: CollectionReference {
        Firestore.firestore().collection("chats")
    }
    
    private func messagesCollection(chatId: String) -> CollectionReference {
        collection.document(chatId).collection("messages")
    }

    func createNewChat(chat: ChatModel) async throws {
        try collection.document(chat.id).setData(from: chat, merge: true)
    }
    
    func addChatMessage(chatId: String, message: ChatMessageModel) async throws {
        // Add chat message to sub collection
        try messagesCollection(chatId: chatId).document(message.id).setData(from: message, merge: true)
        
        // Update chat date modified
        try await collection.document(chatId).updateData([
            ChatModel.CodingKeys.dateModified.rawValue: Date.now
        ])
    }
}
