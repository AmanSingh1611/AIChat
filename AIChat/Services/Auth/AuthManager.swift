//
//  AuthManager.swift
//  AIChat
//
//  Created by Aman on 15/04/26.
//

import Foundation
import SwiftUI

@MainActor
@Observable
class AuthManager {
    
    private(set) var userAuth: UserAuthInfo?
    private let service: AuthService
    private var listener: (any NSObjectProtocol)?
    
    init(service: AuthService) {
        self.service = service
        self.userAuth = service.getAuthenticatedUser()
        self.addAuthListener()
    }
    
    private func addAuthListener() {
        Task {
            for await value in service.addAuthenticatedUserListener(onListenerAttached: { listener in
                self.listener = listener
            }) {
                self.userAuth = value
                print("Auth Listener Success \(value?.uid ?? "no uid")")
            }
        }
    }
    
    func getAuthId() throws -> String {
        guard let uid = userAuth?.uid else {
            throw AuthError.notSignedIn
        }
        return uid
    }
    
    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        try await service.signInAnonymously()
    }
    
    func signInWithApple() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        try await service.signInWithApple()
    }
    
    func signOut() throws {
        try service.signOut()
        userAuth = nil
    }
    
    func deleteAccount() async throws {
        try await service.deleteAccount()
        userAuth = nil
    }
    
    enum AuthError: LocalizedError {
        case notSignedIn
    }
    
}
