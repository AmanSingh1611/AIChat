//
//  AvatarAttributes.swift
//  AIChat
//
//  Created by Aman on 24/03/26.
//

struct AvatarDescriptionBuilder {
    let characterOption: CharacterOption
    let characterAction: CharacterAction
    let characterLocation: CharacterLocation
    
    init(
        characterOption: CharacterOption,
        characterAction: CharacterAction,
        characterLocation: CharacterLocation
    ) {
        self.characterOption = characterOption
        self.characterAction = characterAction
        self.characterLocation = characterLocation
    }
    
    init(avatar: AvatarModel) {
        self.characterOption = avatar.characterOption ?? .default
        self.characterAction = avatar.characterAction ?? .default
        self.characterLocation = avatar.characterLocation ?? .default
    }
    
    var characterDescription: String {
        "A \(characterOption.rawValue) that is \(characterAction.rawValue) in the \(characterLocation.rawValue)"
    }
}

enum CharacterOption: String, Hashable, CaseIterable {
    case man, woman, cat, dog, alien
    
    static var `default`: Self {
        .man
    }
}

enum CharacterAction: String, Hashable, CaseIterable {
    case smiling, sitting, eating, walking, studing, shopping, working, relaxing, fighting, crying
    
    static var `default`: Self {
        .smiling
    }
}

enum CharacterLocation: String, Hashable, CaseIterable {
    case park, mall, museum, city, desert, forest, space
    
    static var `default`: Self {
        .park
    }
}
