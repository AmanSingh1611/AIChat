//
//  TextValidationHelper.swift
//  AIChat
//
//  Created by Aman on 09/04/26.
//
import SwiftUI

struct TextValidationHelper {
    enum TextValidationError: LocalizedError {
        case notEnoughCharacters(min: Int)
        case hasBadWords
        
        var errorDescription: String? {
            switch self {
            case .notEnoughCharacters(min: let min):
                return "Please add atleast \(min) characters."
            case .hasBadWords:
                return "Bad word detected. Please rephrase your message."
            }
        }
    }

    static func checkIfTextIsValid(text: String) throws {
        let minimumCharacterCount = 3

        guard text.count >= minimumCharacterCount else {
            throw TextValidationError.notEnoughCharacters(min: minimumCharacterCount)
        }

        let badWords: [String] = [
            "bitch",
            "ass",
            "shit"
        ]

        if badWords.contains(text.lowercased()) {
            throw TextValidationError.hasBadWords
        }
    }
}
