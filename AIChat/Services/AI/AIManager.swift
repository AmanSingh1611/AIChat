//
//  AIManager.swift
//  AIChat
//
//  Created by Aman on 16/04/26.
//

import Foundation
import SwiftUI

@MainActor
@Observable
class AIManager {
    
    private let imageGenerationService: AIImageGenerationService
    private let textGenerationService: AITextGenerationService
    
    init(imageGenerationService: AIImageGenerationService, textGenerationService: AITextGenerationService) {
        self.imageGenerationService = imageGenerationService
        self.textGenerationService = textGenerationService
    }
    
    func generateImage(input: String) async throws -> UIImage {
        try await imageGenerationService.generateImage(input: input)
    }
    
    func generateText(chats: [AIChatModel]) async throws -> AIChatModel {
        try await textGenerationService.generateText(chats: chats)
    }
}
