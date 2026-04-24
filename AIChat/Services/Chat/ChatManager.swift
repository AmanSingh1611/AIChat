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
}
