//
//  OpenAIService.swift
//  AIChat
//
//  Created by Aman on 16/04/26.
//
import OpenAI
import SwiftUI

struct OpenAIService: AITextGenerationService, AIImageGenerationService {
    var openAI: OpenAI {
        OpenAI(apiToken: "")
    }
    
    func generateImage(input: String) async throws -> UIImage {
        let query = ImagesQuery(
            prompt: input,
            model: .gpt4,
            n: 1,
            quality: .hd,
            responseFormat: .b64_json,
            size: ._512,
            style: .natural,
            user: nil
        )
        
        let result = try await openAI.images(query: query)
        
        guard let b64Json = result.data.first?.b64Json,
              let data = Data(base64Encoded: b64Json),
              let image = UIImage(data: data) else {
            throw OpenAIError.invalidResponse
        }
        
        return image
    }
    
    func generateText(chats: [AIChatModel]) async throws -> AIChatModel {
        let messages: [ChatQuery.ChatCompletionMessageParam] = chats.compactMap { chat in
            switch chat.role {
            case .system:
                return .init(role: .system, content: chat.message)
            case .user:
                return .init(role: .user, content: chat.message)
            case .assistant:
                return .init(role: .assistant, content: chat.message)
            }
        }
        
        let query = ChatQuery(
            messages: messages,
            model: .gpt3_5Turbo
        )
        
        let result = try await openAI.chats(query: query)
        
        guard let content = result.choices.first?.message.content else {
            throw OpenAIError.invalidResponse
        }
        
        return AIChatModel(role: .assistant, content: content)
    }
    
    enum OpenAIError: LocalizedError {
        case invalidResponse
    }
}

import FoundationModels

enum AIChatRole: String, Codable {
    case system, user, assistant
}

struct AIChatModel: Codable {
    let role: AIChatRole
    let message: String
    
    init(role: AIChatRole, content: String) {
        self.role = role
        self.message = content
    }
    
    init(response: LanguageModelSession.Response<String>) {
        self.role = .assistant
        self.message = response.content
    }
}
