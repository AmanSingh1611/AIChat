//
//  MockAIService.swift
//  AIChat
//
//  Created by Aman on 16/04/26.
//
import SwiftUI

struct MockAIService: AIImageGenerationService, AITextGenerationService {
    let delay: Double
    let showError: Bool
    
    init(delay: Double = 0.0, showError: Bool = false) {
        self.delay = delay
        self.showError = showError
    }
    
    private func tryShowError() throws {
        if showError {
            throw URLError(.unknown)
        }
    }
    
    func generateText(chats: [AIChatModel]) async throws -> AIChatModel {
        try? await Task.sleep(for: .seconds(delay))
        try tryShowError()
        return AIChatModel(role: .assistant, content: "Returned text from mock ai")
    }
    
    func generateImage(input: String) async throws -> UIImage {
        try? await Task.sleep(for: .seconds(delay))
        try tryShowError()
        return UIImage(systemName: "star.fill")!
    }
}
