//
//  AvatarModel.swift
//  AIChat
//
//  Created by Aman on 12/02/26.
//

import Foundation

struct AvatarModel: Hashable {
    let avatarId: String
    let name: String?
    let characterOption: CharacterOption?
    let characterAction: CharacterAction?
    let characterLocation: CharacterLocation?
    let profileImageName: String?
    let authodId: String?
    let dateCreated: Date?
    
    init(
        avatarId: String,
        name: String? = nil,
        characterOption: CharacterOption? = nil,
        characterAction: CharacterAction? = nil,
        characterLocation: CharacterLocation? = nil,
        profileImageName: String? = nil,
        authodId: String? = nil,
        dateCreated: Date? = nil
    ) {
        self.avatarId = avatarId
        self.name = name
        self.characterOption = characterOption
        self.characterAction = characterAction
        self.characterLocation = characterLocation
        self.profileImageName = profileImageName
        self.authodId = authodId
        self.dateCreated = dateCreated
    }
    
    var description: String {
        AvatarDescriptionBuilder(avatar: self).characterDescription
    }
    
    static var mock: AvatarModel {
        mocks[0]
    }
    
    static var mocks: [AvatarModel] {
        return [
            AvatarModel(
                avatarId: UUID().uuidString,
                name: "Alpha",
                characterOption: .man,
                characterAction: .smiling,
                characterLocation: .city,
                profileImageName: Constants.randomImage,
                authodId: UUID().uuidString,
                dateCreated: Date()
            ),
            AvatarModel(
                avatarId: UUID().uuidString,
                name: "Beta",
                characterOption: .woman,
                characterAction: .working,
                characterLocation: .mall,
                profileImageName: Constants.randomImage,
                authodId: UUID().uuidString,
                dateCreated: Date()
            ),
            AvatarModel(
                avatarId: UUID().uuidString,
                name: "Gama",
                characterOption: .alien,
                characterAction: .walking,
                characterLocation: .space,
                profileImageName: Constants.randomImage,
                authodId: UUID().uuidString,
                dateCreated: Date()
            ),
            AvatarModel(
                avatarId: UUID().uuidString,
                name: "Delta",
                characterOption: .cat,
                characterAction: .relaxing,
                characterLocation: .park,
                profileImageName: Constants.randomImage,
                authodId: UUID().uuidString,
                dateCreated: Date()
            )
        ]
    }
}
