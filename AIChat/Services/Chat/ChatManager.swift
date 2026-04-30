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
    
    func getAllChats(userId: String) async throws -> [ChatModel] {
        try await service.getAllChats(userId: userId)
    }
    
    func getLastChatMessage(chatId: String) async throws -> ChatMessageModel? {
        try await service.getLastChatMessage(chatId: chatId)
    }
    
    func deleteChat(chatId: String) async throws {
        try await service.deleteChat(chatId: chatId)
    }
    
    func deleteAllChatsForUser(userId: String) async throws {
        try await service.deleteAllChatsForUser(userId: userId)
    }
    
    func reportChat(chatId: String, userId: String) async throws {
        let report = ChatReportModel.new(chatId: chatId, userId: userId)
        try await service.reportChat(report: report)
    }
}
