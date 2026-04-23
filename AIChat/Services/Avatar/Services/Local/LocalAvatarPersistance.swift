//
//  LocalAvatarPersistance.swift
//  AIChat
//
//  Created by Aman on 23/04/26.
//

protocol LocalAvatarPersistance {
    func addRecentAvatar(avatar: AvatarModel) throws
    func getRecentAvatars() throws -> [AvatarModel]
}
