//
//  MockAIService.swift
//  AIChat
//
//  Created by Aman on 16/04/26.
//
import SwiftUI

struct MockAIService: AIService {
    func generateText(chats: [AIChatModel]) async throws -> AIChatModel {
        try? await Task.sleep(for: .seconds(1))
        return AIChatModel(role: .assistant, content: "Returned text from mock ai")
    }
    
    func generateImage(input: String) async throws -> UIImage {
        try? await Task.sleep(for: .seconds(1))
        return UIImage(systemName: "star.fill")!
    }
}
