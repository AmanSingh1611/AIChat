//
//  UserModel.swift
//  AIChat
//
//  Created by Aman on 10/03/26.
//

import Foundation
import SwiftUI

struct UserModel {
    
    let userId: String
    let dateCreated: Date?
    let didCompleteOnboarding: Bool?
    let profileColorHex: String?
    
    init(
        userId: String,
        dateCreated: Date?,
        didCompleteOnboarding: Bool?,
        profileColorHex: String?
    ) {
        self.userId = userId
        self.dateCreated = dateCreated
        self.didCompleteOnboarding = didCompleteOnboarding
        self.profileColorHex = profileColorHex
    }
    
    static var mock: UserModel {
        mocks.first!
    }
    
    static var mocks: [UserModel] {
        let now = Date()
        
        return [
            UserModel(
                userId: "user_1",
                dateCreated: now.addTimeInterval(days: -10),
                didCompleteOnboarding: true,
                profileColorHex: "#4ECDC4"
            ),
            
            UserModel(
                userId: "user_2",
                dateCreated: now.addTimeInterval(days: -8, hours: -3),
                didCompleteOnboarding: true,
                profileColorHex: "#FF6B6B"
            ),
            
            UserModel(
                userId: "user_3",
                dateCreated: now.addTimeInterval(days: -5, minutes: -20),
                didCompleteOnboarding: false,
                profileColorHex: "#556270"
            ),
            
            UserModel(
                userId: "user_4",
                dateCreated: now.addTimeInterval(days: -2, hours: -4),
                didCompleteOnboarding: true,
                profileColorHex: "#C7F464"
            )
        ]
    }
    
    var profileColorCalculated: Color {
        guard let profileColorHex else {
            return .accent
        }
        return Color(hex: profileColorHex)
    }
}
