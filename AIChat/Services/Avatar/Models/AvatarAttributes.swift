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
    
    enum CodingKeys: String, CodingKey {
        case characterOption = "character_option"
        case characterAction = "character_action"
        case characterLocation = "character_location"
    }
    
    var characterDescription: String {
        "A \(characterOption.rawValue) that is \(characterAction.rawValue) in the \(characterLocation.rawValue)"
    }
    
    var eventParameters: [String: Any] {
        [
            CodingKeys.characterOption.rawValue: characterOption.rawValue,
            CodingKeys.characterAction.rawValue: characterAction.rawValue,
            CodingKeys.characterLocation.rawValue: characterLocation.rawValue,
            "character_description": characterDescription
        ]
    }
}

enum CharacterOption: String, Hashable, CaseIterable, Codable {
    case man, woman, cat, dog, alien
    
    var plural: String {
        switch self {
        case .man:
            "men"
        case .woman:
            "women"
        case .cat:
            "cats"
        case .dog:
            "dogs"
        case .alien:
            "aliens"
        }
    }
    static var `default`: Self {
        .man
    }
}

enum CharacterAction: String, Hashable, CaseIterable, Codable {
    case smiling, sitting, eating, walking, studing, shopping, working, relaxing, fighting, crying
    
    static var `default`: Self {
        .smiling
    }
}

enum CharacterLocation: String, Hashable, CaseIterable, Codable {
    case park, mall, museum, city, desert, forest, space
    
    static var `default`: Self {
        .park
    }
}
