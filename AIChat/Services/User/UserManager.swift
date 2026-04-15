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
    func addListner(to userId: String) -> AsyncThrowingStream<UserModel?, Error>
    func deleteUser(userId: String) async throws
    func markOnboardingCompleted(userId: String, profileColorHex: String) async throws
}

struct MockUserService: UserService {
    
    let currentUser: UserModel?
    
    init(user: UserModel? = nil) {
        self.currentUser = user
    }
    
    func saveUser(user: UserModel) async throws {
        
    }
    
    func addListner(to userId: String) -> AsyncThrowingStream<UserModel?, any Error> {
        AsyncThrowingStream { continuation in
            if let currentUser {
                continuation.yield(currentUser)
            }
        }
    }
    
    func deleteUser(userId: String) async throws {
        
    }
    
    func markOnboardingCompleted(userId: String, profileColorHex: String) async throws {
        
    }

}

import FirebaseFirestore
import SwiftfulFirestore

struct FirebaseUserService: UserService {
    var collection: CollectionReference {
        Firestore.firestore().collection("users")
    }
    
    func saveUser(user: UserModel) async throws {
        try collection.document(user.userId).setData(from: user, merge: true)
    }
    
    func addListner(to userId: String) -> AsyncThrowingStream<UserModel?, any Error> {
        AsyncThrowingStream { continuation in
             _ = collection.document(userId).addSnapshotListener { snapshot, error in
                if let error {
                    continuation.finish(throwing: error)
                    return
                }
                
                guard let snapshot else {
                    continuation.yield(nil)
                    return
                }
                
                do {
                    let model = try snapshot.data(as: UserModel.self)
                    
                    continuation.yield(model)
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    func deleteUser(userId: String) async throws {
        try await collection.document(userId).delete()
    }
    
    func markOnboardingCompleted(userId: String, profileColorHex: String) async throws {
        try await collection.document(userId).setData([
            UserModel.CodingKeys.didCompleteOnboarding.rawValue: true,
            UserModel.CodingKeys.profileColorHex.rawValue: profileColorHex
        ])
    }
}

@MainActor
@Observable
class UserManager {
    private let service: UserService
    var currentUser: UserModel?
    private var listenerTask: Task<Void, Never>?
    
    init(service: UserService) {
        self.service = service
    }
    
    func logIn(userAuth: UserAuthInfo, isNewUser: Bool) async throws {
        let creationVersion = isNewUser ? Utilities.appVersion : nil
        
        let user = UserModel(userAuth: userAuth, creationVersion: creationVersion)
        try await service.saveUser(user: user)
        addCurrentUserListner(userId: user.userId)
        
    }
    
    func addCurrentUserListner(userId: String) {
        listenerTask = Task {
            do {
                for try await value in service.addListner(to: userId) {
                    self.currentUser = value
                    print("Successfully added listener to user \(value?.userId ?? "no id")")
                }
            } catch {
                print("Error with adding listner to user: \(error)")
            }
        }
    }
    
    func markOnboardingCompleteForCurrentuser(profileColorHex: String) async throws {
        let userId = try currentUserId()
        try await service.markOnboardingCompleted(userId: userId, profileColorHex: profileColorHex)
    }
    
    func signOut() {
        currentUser = nil
        listenerTask?.cancel()
        listenerTask = nil
    }
    
    func deleteCurrentUser() async throws {
        let userId = try currentUserId()
        try await service.deleteUser(userId: userId)
        signOut()
    }
    
    func currentUserId() throws -> String {
        guard let userId = currentUser?.userId else {
            throw UserManagerError.noUserId
        }
        return userId
    }
    
    enum UserManagerError: LocalizedError {
        case noUserId
    }
}
