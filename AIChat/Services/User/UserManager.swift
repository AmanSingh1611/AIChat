//
//  UserManager.swift
//  AIChat
//
//  Created by Aman on 15/04/26.
//

import Foundation
import SwiftUI
import SwiftfulUtilities

protocol UserService: Sendable {
    func saveUser(user: UserModel) async throws
}

import FirebaseFirestore
struct FirebaseUserService: UserService {
    var collection : CollectionReference {
        Firestore.firestore().collection("users")
    }
    
    func saveUser(user: UserModel) async throws {
        try collection.document(user.userId).setData(from: user, merge: true)
    }
}

@MainActor
@Observable
class UserManager {
    
    private(set) var currentUser: UserModel?
    private let service: UserService
    
    init(service: UserService) {
        self.service = service
        self.currentUser = nil
    }
    
    func logIn(userAuth: UserAuthInfo, isNewUser: Bool) async throws {
        let creationVersion = isNewUser ? Utilities.appVersion : nil
        
        let user = UserModel(userAuth: userAuth, creationVersion: creationVersion)
        try await service.saveUser(user: user)
    }
}
