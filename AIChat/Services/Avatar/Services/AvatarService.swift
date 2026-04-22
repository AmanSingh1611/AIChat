//
//  AvatarService.swift
//  AIChat
//
//  Created by Aman on 22/04/26.
//

import SwiftUI

protocol AvatarService {
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws
    func getFeaturedAvatars() async throws -> [AvatarModel]
    func getPopularAvatars() async throws -> [AvatarModel]
    func getAvatarForCategory(category: CharacterOption) async throws -> [AvatarModel]
    func getAvatarForAuthor(userId: String) async throws -> [AvatarModel]
}
