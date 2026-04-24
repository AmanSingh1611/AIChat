//
//  FoundationModelService.swift
//  AIChat
//
//  Created by Aman on 24/04/26.
//
import FoundationModels
import SwiftUI

final class FoundationModelService: AITextGenerationService {
    private var session: LanguageModelSession?
    
    func generateText(chats: [AIChatModel]) async throws -> AIChatModel {
        guard SystemLanguageModel.default.isAvailable else {
            throw FoundationModelError.modelUnavailable
        }
        
        if session == nil {
            let systemPrompt = chats
                .filter { $0.role == .system }
                .map { $0.message }
                .joined(separator: "\n")
            
            session = LanguageModelSession(instructions: systemPrompt)
        }
        
        guard let userMessage = chats.last(where: { $0.role == .user })?.message else {
            throw FoundationModelError.noUserMessage
        }
        
        let response = try await session!.respond(to: userMessage)
        return AIChatModel(role: .assistant, content: response.content)
    }
    
    enum FoundationModelError: LocalizedError {
        case modelUnavailable
        case noUserMessage
        
        var errorDescription: String? {
            switch self {
            case .modelUnavailable: return "Apple Intelligence is not available."
            case .noUserMessage: return "No user message found."
            }
        }
    }
}
