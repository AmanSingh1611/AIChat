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
    private let remote: RemoteAvatarService
    private let local: LocalAvatarPersistance
    
    init(service: RemoteAvatarService, local: LocalAvatarPersistance) {
        self.remote = service
        self.local  = local
    }
    
    func getRecentAvatars() throws -> [AvatarModel] {
        try local.getRecentAvatars()
    }
    
    func addRecentAvatar(avatar: AvatarModel) throws {
        try local.addRecentAvatar(avatar: avatar)
    }
    
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws {
        try await remote.createAvatar(avatar: avatar, image: image)
    }
    
    func getFeaturedAvatars() async throws -> [AvatarModel] {
        try await remote.getFeaturedAvatars()
    }
    
    func getPopularAvatars() async throws -> [AvatarModel] {
        try await remote.getPopularAvatars()
    }
    
    func getAvatarForCategory(category: CharacterOption) async throws -> [AvatarModel] {
        try await remote.getAvatarForCategory(category: category)
    }
    
    func getAvatarForAuthor(userId: String) async throws -> [AvatarModel] {
        try await remote.getAvatarForAuthor(userId: userId)
    }
    
    func getAvatar(id: String) async throws -> AvatarModel {
        try await remote.getAvatar(id: id)
    }
}
