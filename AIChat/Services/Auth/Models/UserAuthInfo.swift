//
//  UserAuthInfo.swift
//  AIChat
//
//  Created by Aman on 13/04/26.
//

import Foundation

struct UserAuthInfo: Sendable {
    let uid: String
    let email: String?
    let isAnonymous: Bool
    let creationDate: Date?
    let lastSignInDate: Date?
    
    init(
        uid: String,
        email: String? = nil,
        isAnonymous: Bool = false,
        creationDate: Date? = nil,
        lastSignInDate: Date? = nil
    ) {
        self.uid = uid
        self.email = email
        self.isAnonymous = isAnonymous
        self.creationDate = creationDate
        self.lastSignInDate = lastSignInDate
    }
    
    enum CodingKeys: String, CodingKey {
        case uid
        case email
        case isAnonymous = "is_anonymous"
        case creationDate = "creation_date"
        case lastSignInDate = "last_sign_in_date"
    }
    
    static func mock(isAnonymous: Bool = false) -> Self {
        UserAuthInfo(
            uid: "mock_user_1",
            email: "aman@gmail.com",
            isAnonymous: isAnonymous,
            creationDate: .now,
            lastSignInDate: .now
        )
    }
    
    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "uauth_\(CodingKeys.uid.rawValue)": uid,
            "uauth_\(CodingKeys.email.rawValue)": email,
            "uauth_\(CodingKeys.isAnonymous.rawValue)": isAnonymous,
            "uauth_\(CodingKeys.creationDate.rawValue)": creationDate,
            "uauth_\(CodingKeys.lastSignInDate.rawValue)": lastSignInDate
        ]
        return dict.compactMapValues({ $0 })
    }
    
}
