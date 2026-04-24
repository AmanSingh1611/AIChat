//
//  AIServices.swift
//  AIChat
//
//  Created by Aman on 24/04/26.
//
import SwiftUI

protocol AIImageGenerationService {
    func generateImage(input: String) async throws -> UIImage
}

protocol AITextGenerationService {
    func generateText(chats: [AIChatModel]) async throws -> AIChatModel
}
