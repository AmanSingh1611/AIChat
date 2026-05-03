//
//  UserModel.swift
//  AIChat
//
//  Created by Aman on 10/03/26.
//

import Foundation
import SwiftUI

struct UserModel: Codable {
    
    let userId: String
    let email: String?
    let isAnonymous: Bool?
    let lastSignInDate: Date?
    let creationDate: Date?
    let didCompleteOnboarding: Bool?
    let profileColorHex: String?
    let creationVersion: String?
    
    init(
        userId: String,
        email: String? = nil,
        isAnonymous: Bool? = nil,
        lastSignInDate: Date? = nil,
        creationDate: Date? = nil,
        didCompleteOnboarding: Bool? = nil,
        profileColorHex: String? = nil,
        creationVersion: String? = nil
    ) {
        self.userId = userId
        self.email = email
        self.isAnonymous = isAnonymous
        self.lastSignInDate = lastSignInDate
        self.creationDate = creationDate
        self.didCompleteOnboarding = didCompleteOnboarding
        self.profileColorHex = profileColorHex
        self.creationVersion = creationVersion
    }
    
    init(userAuth: UserAuthInfo, creationVersion: String?) {
        self.init(
            userId: userAuth.uid,
            email: userAuth.email,
            isAnonymous: userAuth.isAnonymous,
            lastSignInDate: userAuth.lastSignInDate,
            creationDate: userAuth.creationDate,
            creationVersion: creationVersion
        )
    }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case email
        case isAnonymous = "is_anonymous"
        case lastSignInDate = "last_sign_date_date"
        case creationDate = "creation_date"
        case didCompleteOnboarding = "did_complete_onboarding"
        case profileColorHex = "profile_color_hex"
        case creationVersion = "creation_version"
    }
    
    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "user_\(CodingKeys.userId.rawValue)": userId,
            "user_\(CodingKeys.email.rawValue)": email,
            "user_\(CodingKeys.isAnonymous.rawValue)": isAnonymous,
            "user_\(CodingKeys.creationDate.rawValue)": creationDate,
            "user_\(CodingKeys.creationVersion.rawValue)": creationVersion,
            "user_\(CodingKeys.lastSignInDate.rawValue)": lastSignInDate,
            "user_\(CodingKeys.didCompleteOnboarding.rawValue)": didCompleteOnboarding,
            "user_\(CodingKeys.profileColorHex.rawValue)": profileColorHex
        ]
        return dict.compactMapValues({ $0 })
    }
    
    static var mock: UserModel {
        mocks.first!
    }
    
    static var mocks: [UserModel] {
        let now = Date()
        
        return [
            UserModel(
                userId: "user_1",
                creationDate: now.addTimeInterval(days: -10),
                didCompleteOnboarding: true,
                profileColorHex: "#4ECDC4"
            ),
            
            UserModel(
                userId: "user_2",
                creationDate: now.addTimeInterval(days: -8, hours: -3),
                didCompleteOnboarding: true,
                profileColorHex: "#FF6B6B"
            ),
            
            UserModel(
                userId: "user_3",
                creationDate: now.addTimeInterval(days: -5, minutes: -20),
                didCompleteOnboarding: false,
                profileColorHex: "#556270"
            ),
            
            UserModel(
                userId: "user_4",
                creationDate: now.addTimeInterval(days: -2, hours: -4),
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
