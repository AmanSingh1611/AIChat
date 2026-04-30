//
//  UserManager.swift
//  AIChat
//
//  Created by Aman on 15/04/26.
//

import SwiftUI
import SwiftfulUtilities

@MainActor
@Observable
class UserManager {
    private let remote: RemoteUserService
    private let local: LocalUserPersistence
    
    private(set) var currentUser: UserModel?
    private var listenerTask: Task<Void, Never>?
    
    init(services: UserServices) {
        self.remote = services.remote
        self.local = services.local
        self.currentUser = local.getCurrentUser()
    }
    
    func logIn(userAuth: UserAuthInfo, isNewUser: Bool) async throws {
        let creationVersion = isNewUser ? Utilities.appVersion : nil
        
        let user = UserModel(userAuth: userAuth, creationVersion: creationVersion)
        try await remote.saveUser(user: user)
        addCurrentUserListener(userId: user.userId)
        
    }
    
    func addCurrentUserListener(userId: String) {
        listenerTask?.cancel()

        listenerTask = Task {
            do {
                for try await value in remote.addListener(to: userId) {
                    self.currentUser = value
                    self.saveCurrentUserLocally()
                    print("Successfully added listener to user \(value?.userId ?? "no id")")
                }
            } catch {
                print("Error with adding listner to user: \(error)")
            }
        }
    }
    
    func markOnboardingCompleteForCurrentuser(profileColorHex: String) async throws {
        let userId = try currentUserId()
        try await remote.markOnboardingCompleted(userId: userId, profileColorHex: profileColorHex)
    }
    
    func signOut() {
        currentUser = nil
        listenerTask?.cancel()
        listenerTask = nil
    }
    
    func deleteCurrentUser() async throws {
        let userId = try currentUserId()
        try await remote.deleteUser(userId: userId)
        signOut()
    }
    
    func currentUserId() throws -> String {
        guard let userId = currentUser?.userId else {
            throw UserManagerError.noUserId
        }
        return userId
    }
    
    func saveCurrentUserLocally() {
        Task {
            do {
                try local.saveCurrentUser(user: currentUser)
                print("Success saved current user locally.")
            } catch {
                print("Error saving current user locally \(error).")
            }
        }
    }
    
    enum UserManagerError: LocalizedError {
        case noUserId
    }
}
