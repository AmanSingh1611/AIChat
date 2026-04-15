//
//  CreateAccountView.swift
//  AIChat
//
//  Created by Aman on 24/03/26.
//

import SwiftUI
import AuthenticationServices

struct CreateAccountView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(\.dismiss) private var dismiss
    
    var title: String = "Create Account?"
    var subTitle: String = "Don't lose your data! connect to an SSO provider to save your account"
    var onDidSignIn: ((_ isNewUser: Bool) -> Void)?
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                
                Text(subTitle)
                    .font(.body)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            SignInWithAppleButtonView(
                type: .signIn,
                style: .black,
                cornerRadius: 10
            )
            .frame(height: 55)
            .anyButton(.press) {
                onSignInApplePressed()
            }
            
            Spacer()
        }
        .padding(16)
        .padding(.top, 40)
    }
    
    func onSignInApplePressed() {
        Task {
            do {
                let result = try await authManager.signInWithApple()
                print("Did sign in with apple. \(result.user.uid)")
                try await userManager.logIn(userAuth: result.user, isNewUser: result.isNewUser)
                print("Did log in")
                
                onDidSignIn?(result.isNewUser)
                dismiss()
            } catch {
                print("Error sign in with apple.")
            }
        }
    }
}

#Preview {
    CreateAccountView()
}
