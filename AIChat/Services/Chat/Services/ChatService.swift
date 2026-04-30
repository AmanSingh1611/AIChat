//
//  ChatService.swift
//  AIChat
//
//  Created by Aman on 24/04/26.
//
import SwiftUI
import SwiftfulUtilities

protocol ChatService: Sendable {
    func createNewChat(chat: ChatModel) async throws
    func addChatMessage(chatId: String, message: ChatMessageModel) async throws
    func getChat(userId: String, avatarId: String) async throws -> ChatModel?
    func streamChatMessages(chatId: String) -> AsyncThrowingStream<[ChatMessageModel], any Error>
}

struct MockChatService: ChatService {
    func streamChatMessages(chatId: String) -> AsyncThrowingStream<[ChatMessageModel], any Error> {
        AsyncThrowingStream { continuation in
            
        }
    }
    
    func getChat(userId: String, avatarId: String) async throws -> ChatModel? {
        ChatModel.mock
    }
    
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
    
    func getChat(userId: String, avatarId: String) async throws -> ChatModel? {
//        let result: [ChatModel] = try await collection
//            .whereField(ChatModel.CodingKeys.userId.rawValue, isEqualTo: userId)
//            .whereField(ChatModel.CodingKeys.avatarId.rawValue, isEqualTo: avatarId)
//            .getAllDocuments()
//        return result.first
        
        try await collection.getDocument(id: ChatModel.chatId(userId: userId, avatarId: avatarId))
    }
    
    func addChatMessage(chatId: String, message: ChatMessageModel) async throws {
        // Add chat message to sub collection
        try messagesCollection(chatId: chatId).document(message.id).setData(from: message, merge: true)
        
        // Update chat date modified
        try await collection.document(chatId).updateData([
            ChatModel.CodingKeys.dateModified.rawValue: Date.now
        ])
    }
    
    func streamChatMessages(chatId: String) -> AsyncThrowingStream<[ChatMessageModel], any Error> {
        messagesCollection(chatId: chatId).streamAllDocuments()
    }
}
