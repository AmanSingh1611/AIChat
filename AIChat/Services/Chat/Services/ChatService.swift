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
    func getAllChats(userId: String) async throws -> [ChatModel]
    func getLastChatMessage(chatId: String) async throws -> ChatMessageModel?
    func deleteChat(chatId: String) async throws
    func deleteAllChatsForUser(userId: String) async throws
    func reportChat(report: ChatReportModel) async throws
}
