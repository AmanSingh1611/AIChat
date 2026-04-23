//
//  AvatarEntity.swift
//  AIChat
//
//  Created by Aman on 23/04/26.
//

import SwiftUI
import SwiftData

@Model
class AvatarEntity {
    @Attribute(.unique) var avatarId: String
    var name: String?
    var characterOption: CharacterOption?
    var characterAction: CharacterAction?
    var characterLocation: CharacterLocation?
    var profileImageName: String?
    var authorId: String?
    var dateCreated: Date?
    var dateAdded: Date
    
    init(from model: AvatarModel) {
        self.avatarId = model.avatarId
        self.name = model.name
        self.characterOption = model.characterOption
        self.characterAction = model.characterAction
        self.characterLocation = model.characterLocation
        self.profileImageName = model.profileImageName
        self.authorId = model.authorId
        self.dateCreated = model.dateCreated
        self.dateAdded = .now
    }
    
    func toModel() -> AvatarModel {
        AvatarModel(
            avatarId: avatarId,
            name: name,
            characterOption: characterOption,
            characterAction: characterAction,
            characterLocation: characterLocation,
            profileImageName: profileImageName,
            authorId: authorId,
            dateCreated: dateCreated
        )
    }
}
