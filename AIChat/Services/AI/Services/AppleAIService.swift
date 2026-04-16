//
//  AppleAIService.swift
//  AIChat
//
//  Created by Aman on 16/04/26.
//

import ImagePlayground
import SwiftUI

@available(iOS 18.1, *)
struct AppleAIService: AIService {
    
    func generateImage(input: String) async throws -> UIImage {
        let creator = try await ImageCreator()
        
        let images = creator.images(
            for: [.text(input)],
            style: .animation,
            limit: 1
        )
        
        var iterator = images.makeAsyncIterator()
        
        guard let result = try await iterator.next() else {
            throw AppleAIServiceError.cannotGenerateImage
        }
        
        return UIImage(cgImage: result.cgImage)
    }
}

enum AppleAIServiceError: LocalizedError {
    case cannotGenerateImage
    
    var errorDescription: String? {
        switch self {
        case .cannotGenerateImage:
            return "Cannot generate image"
        }
    }
}
