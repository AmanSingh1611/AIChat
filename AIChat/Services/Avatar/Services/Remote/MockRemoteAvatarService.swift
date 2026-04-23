//
//  MockRemoteAvatarService.swift
//  AIChat
//
//  Created by Aman on 22/04/26.
//

import SwiftUI

struct MockRemoteAvatarService: RemoteAvatarService {
    let avatars: [AvatarModel]
    let delay: Double
    let showError: Bool
    
    init(
        avatars: [AvatarModel] = AvatarModel.mocks,
        delay: Double = 2.0,
        showError: Bool = false
    ) {
        self.avatars = avatars
        self.delay = delay
        self.showError = showError
    }
    
    private func tryShowError() throws {
        if showError {
            throw URLError(.unknown)
        }
    }
    
    func incrementAvatarClickCount(avatarId: String) async throws {
        
    }
    
    func getAvatar(id: String) async throws -> AvatarModel {
        try tryShowError()
        guard let avatar = avatars.first(where: { avatar in
            avatar.id == id
        }) else {
            throw URLError(.unknown)
        }
        
        return avatar
    }
    
    func getAvatarForAuthor(userId: String) async throws -> [AvatarModel] {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        return avatars.filter { avatar in
            avatar.authorId == userId
        }
    }
    
    func getAvatarForCategory(category: CharacterOption) async throws -> [AvatarModel] {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        return avatars.filter { avatar in
            avatar.characterOption == category
        }
    }
    
    func getFeaturedAvatars() async throws -> [AvatarModel] {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        return avatars.shuffled()
    }
    
    func getPopularAvatars() async throws -> [AvatarModel] {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        return avatars.shuffled()
    }
    
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws {
        try tryShowError()
    }
}
