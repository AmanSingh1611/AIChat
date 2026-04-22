//
//  MockAvatarService.swift
//  AIChat
//
//  Created by Aman on 22/04/26.
//

import SwiftUI

struct MockAvatarService: AvatarService {
    func getAvatarForAuthor(userId: String) async throws -> [AvatarModel] {
        AvatarModel.mocks.filter { avatar in
            avatar.authorId == userId
        }
    }
    
    func getAvatarForCategory(category: CharacterOption) async throws -> [AvatarModel] {
        AvatarModel.mocks.filter { avatar in
            avatar.characterOption == category
        }
    }
    
    func getFeaturedAvatars() async throws -> [AvatarModel] {
        AvatarModel.mocks.shuffled()
    }
    
    func getPopularAvatars() async throws -> [AvatarModel] {
        AvatarModel.mocks.shuffled()
    }
    
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws {
        
    }
}
