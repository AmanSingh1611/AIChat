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
    @Environment(LogManager.self) private var logManager
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
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                
                Text(subTitle)
                    .font(.body)
                    .lineLimit(4)
                    .minimumScaleFactor(0.5)
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
        .screenAppearAnalytics(name: "CreateAccountView")
    }
    
    func onSignInApplePressed() {
        logManager.trackEvent(event: Event.appleAuthStart)
        
        Task {
            do {
                let result = try await authManager.signInWithApple()
                logManager.trackEvent(event: Event.appleAuthSuccess(user: result.user, isNewUser: result.isNewUser))
                
                try await userManager.logIn(userAuth: result.user, isNewUser: result.isNewUser)
                logManager.trackEvent(event: Event.appleAuthLoginSuccess(user: result.user, isNewUser: result.isNewUser))
                
                onDidSignIn?(result.isNewUser)
                dismiss()
            } catch {
                logManager.trackEvent(event: Event.appleAuthFail(error: error))
            }
        }
    }
    
    enum Event: LoggableEvent {
        case appleAuthStart
        case appleAuthSuccess(user: UserAuthInfo, isNewUser: Bool)
        case appleAuthLoginSuccess(user: UserAuthInfo, isNewUser: Bool)
        case appleAuthFail(error: Error)

        var eventName: String {
            switch self {
            case .appleAuthStart:          return "CreateAccountView_AppleAuth_Start"
            case .appleAuthSuccess:        return "CreateAccountView_AppleAuth_Success"
            case .appleAuthLoginSuccess:   return "CreateAccountView_AppleAuth_LoginSuccess"
            case .appleAuthFail:           return "CreateAccountView_AppleAuth_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .appleAuthSuccess(user: let user, isNewUser: let isNewUser),
                    .appleAuthLoginSuccess(user: let user, isNewUser: let isNewUser):
                var dict = user.eventParameters
                dict["is_new_user"] = isNewUser
                return dict
            case .appleAuthFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .appleAuthFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}

#Preview {
    CreateAccountView()
        .previewEnvironment()
}
