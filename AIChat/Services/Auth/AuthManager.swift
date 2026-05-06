//
//  AuthManager.swift
//  AIChat
//
//  Created by Aman on 15/04/26.
//

import Foundation
import SwiftUI
import SwiftfulUtilities

@MainActor
@Observable
class AuthManager {
    
    private(set) var userAuth: UserAuthInfo?
    private let service: AuthService
    private let logManager: LogManager?
    private var listener: (any NSObjectProtocol)?
    
    init(service: AuthService, logManager: LogManager? = nil) {
        self.service = service
        self.logManager = logManager
        self.userAuth = service.getAuthenticatedUser()
        self.addAuthListener()
    }
    
    private func addAuthListener() {
        logManager?.trackEvent(event: Event.authListenerStart)
        if let listener {
            service.removeAuthenticatedUserListener(listener: listener)
        }
        
        Task {
            for await value in service.addAuthenticatedUserListener(onListenerAttached: { listener in
                self.listener = listener
            }) {
                self.userAuth = value
                logManager?.trackEvent(event: Event.authListenerSuccess(user: value))
                
                if let value {
                    logManager?.identifyUser(userId: value.uid, name: nil, email: value.email)
                    logManager?.addUserProperties(dict: value.eventParameters, isHighPriority: true)
                    logManager?.addUserProperties(dict: Utilities.eventParameters, isHighPriority: false)
                }
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
        defer {
            addAuthListener()
        }
        return try await service.signInWithApple()
    }
    
    func signOut() throws {
        logManager?.trackEvent(event: Event.signOutStart)
        
        try service.signOut()
        userAuth = nil
        logManager?.trackEvent(event: Event.signOutSuccess)
    }
    
    func deleteAccount() async throws {
        logManager?.trackEvent(event: Event.deleteAccountStart)
        
        try await service.deleteAccount()
        userAuth = nil
        logManager?.trackEvent(event: Event.deleteAccountSuccess)
    }
    
    enum AuthError: LocalizedError {
        case notSignedIn
    }
    
    enum Event: LoggableEvent {
        case authListenerStart
        case authListenerSuccess(user: UserAuthInfo?)
        case signOutStart
        case signOutSuccess
        case deleteAccountStart
        case deleteAccountSuccess
        
        var eventName: String {
            switch self {
            case .authListenerStart:        return "AuthMan_AuthListener_Start"
            case .authListenerSuccess:      return "AuthMan_AuthListener_Success"
            case .signOutStart:             return "AuthMan_SignOut_Start"
            case .signOutSuccess:           return "AuthMan_SignOut_Success"
            case .deleteAccountStart:       return "AuthMan_DeleteAccount_Start"
            case .deleteAccountSuccess:     return "AuthMan_DeleteAccount_Success"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .authListenerSuccess(user: let user):
                return user?.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            default:
                return .analytic
            }
        }
    }
    
}
