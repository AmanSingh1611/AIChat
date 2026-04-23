//
//  MockLocalAvatarPersistence.swift
//  AIChat
//
//  Created by Aman on 23/04/26.
//

@MainActor
struct MockLocalAvatarPersistence: LocalAvatarPersistence {
    func addRecentAvatar(avatar: AvatarModel) throws {
       
    }
    
    func getRecentAvatars() throws -> [AvatarModel] {
        return AvatarModel.mocks.shuffled()
    }
}
