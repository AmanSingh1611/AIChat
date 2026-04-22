//
//  AvatarManager.swift
//  AIChat
//
//  Created by Aman on 17/04/26.
//

import SwiftUI

@MainActor
@Observable
class AvatarManager {
    private let service: AvatarService
    
    init(service: AvatarService) {
        self.service = service
    }
    
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws {
        try await service.createAvatar(avatar: avatar, image: image)
    }
    
    func getFeaturedAvatars() async throws -> [AvatarModel] {
        try await service.getFeaturedAvatars()
    }
    
    func getPopularAvatars() async throws -> [AvatarModel] {
        try await service.getPopularAvatars()
    }
    
    func getAvatarForCategory(category: CharacterOption) async throws -> [AvatarModel] {
        try await service.getAvatarForCategory(category: category)
    }
    
    func getAvatarForAuthor(userId: String) async throws -> [AvatarModel] {
        try await service.getAvatarForAuthor(userId: userId)
    }
    
}
