//
//  ChatManager.swift
//  AIChat
//
//  Created by Aman on 24/04/26.
//
import SwiftUI

@MainActor
@Observable
class ChatManager {
    private let service: ChatService
    
    init(service: ChatService) {
        self.service = service
    }
    
    func createNewChat(chat: ChatModel) async throws {
        try await service.createNewChat(chat: chat)
    }
    
    func addChatMessage(chatId: String, message: ChatMessageModel) async throws {
        try await service.addChatMessage(chatId: chatId, message: message)
    }
    
    func getChat(userId: String, avatarId: String) async throws -> ChatModel? {
        try await service.getChat(userId: userId, avatarId: avatarId)
    }
    
    func streamChatMessages(chatId: String) -> AsyncThrowingStream<[ChatMessageModel], any Error> {
        service.streamChatMessages(chatId: chatId)
    }
}
