//
//  FirebaseAuthService.swift
//  AIChat
//
//  Created by Aman on 13/04/26.
//

import FirebaseAuth
import SwiftUI
import SignInAppleAsync

struct FirebaseAuthService: AuthService {
    
    func addAuthenticatedUserListener(onListenerAttached: (any NSObjectProtocol) -> Void) -> AsyncStream<UserAuthInfo?> {
        AsyncStream { continuation in
            let listner = Auth.auth().addStateDidChangeListener { _, currentUser in
                if let currentUser {
                    let user = UserAuthInfo(user: currentUser)
                    continuation.yield(user)
                } else {
                    continuation.yield(nil)
                }
            }
            
            onListenerAttached(listner)
        }
    }
    
    func removeAuthenticatedUserListener(listener: any NSObjectProtocol) {
        Auth.auth().removeStateDidChangeListener(listener)
    }
    
    func getAuthenticatedUser() -> UserAuthInfo? {
        if let user = Auth.auth().currentUser {
            return UserAuthInfo(user: user)
        }
        return nil
    }
    
    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        let result = try await Auth.auth().signInAnonymously()
        return result.asAuthInfo
    }
    
    func signInWithApple() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        let helper = SignInWithAppleHelper()
        let response = try await helper.signIn()
        
        let credential = OAuthProvider.credential(
            providerID: AuthProviderID.apple,
            idToken: response.token,
            rawNonce: response.nonce
        )
        
        /// Try to link the existing anonymous user
        if let user = Auth.auth().currentUser, user.isAnonymous {
            do {
                let result =  try await user.link(with: credential)
                return result.asAuthInfo
            } catch let error as NSError {
                let authError = AuthErrorCode(rawValue: error.code)
                
                switch authError {
                case .providerAlreadyLinked, .credentialAlreadyInUse:
                    if let secondaryCredential = error.userInfo["FIRAuthErrorUserInfoUpdatedCredentialKey"] as? AuthCredential {
                        let result = try await Auth.auth().signIn(with: secondaryCredential)
                        return result.asAuthInfo
                    }
                default:
                    break
                }
            }
        }
        
        /// Sign in to new account
        let result = try await Auth.auth().signIn(with: credential)
        return result.asAuthInfo
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.userNotFound
        }
        do {
            try await user.delete()
        } catch let error as NSError {
            let authError = AuthErrorCode(rawValue: error.code)
            
            switch authError {
            case .requiresRecentLogin:
                try await reauthenticateUser(error: error)
                
                // Reauth successfull
                return try await user.delete()
            default:
                break
            }
        }
    }
    
    private func reauthenticateUser(error: Error) async throws {
        guard let user = Auth.auth().currentUser, let providerID = user.providerData.first?.providerID else {
            throw AuthError.userNotFound
        }
    
        switch providerID {
        case "apple.com":
            let result = try await signInWithApple()
            guard user.uid == result.user.uid else {
                throw AuthError.reauthAccountChanged
            }
        default:
            throw error
        }
        
    }
}

extension AuthDataResult {
    var asAuthInfo: (user: UserAuthInfo, isNewUser: Bool) {
        let user = UserAuthInfo(user: user)
        let isNewUser = additionalUserInfo?.isNewUser ?? true
        
        return (user, isNewUser)
    }
}

enum AuthError: LocalizedError {
    case userNotFound
    case reauthAccountChanged
    
    var errorDescription: String? {
        switch self {
        case .userNotFound:
            "Current authenticated user not found."
        case .reauthAccountChanged:
            "Reauthenticated switched accounts. Please check your account."
        }
    }
    }
