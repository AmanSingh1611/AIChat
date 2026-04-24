//
//  FoundationModelService.swift
//  AIChat
//
//  Created by Aman on 24/04/26.
//
import FoundationModels
import SwiftUI

final class FoundationModelService: AIService {
    private var session: LanguageModelSession?
    
    func generateImage(input: String) async throws -> UIImage {
        try await Task.sleep(for: .seconds(3))
        let mockImages = (1...6).compactMap { UIImage(named: "MockAI/\($0)") }
        return mockImages.randomElement()!
    }
    
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
