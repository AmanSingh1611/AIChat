//
//  AppView.swift
//  AIChat
//
//  Created by Aman on 06/01/26.
//

import SwiftUI

struct AppView: View {
    @State var appState: AppState = AppState()
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(LogManager.self) private var logManager
    
    var body: some View {
        AppViewBuilder(
            showTabBarView: appState.showTabBarView,
            tabbarView: {
                TabBarView()
            },
            onboardingView: {
                WelcomeView()
            }
        )
        .environment(appState)
        .task {
            await checkUserStatus()
        }
        .onAppear {
            logManager.identifyUser(userId: "abc123", name: "aman", email: "hi@aman.com")
            logManager.addUserProperties(dict: UserModel.mock.eventParameters, isHighPriority: false)
            
            logManager.trackEvent(event: Event.alpha)
            logManager.trackEvent(event: Event.beta)
            logManager.trackEvent(event: Event.gamma)
            logManager.trackEvent(event: Event.delta)
            
            let event = AnyLoggableEvent(
                eventName: "MyNewEvent",
                parameters: UserModel.mock.eventParameters,
                type: .analytic
            )
            logManager.trackEvent(event: event)
            
            logManager.trackEvent(eventName: "AnotherEverIsHere")
        }
        .onChange(of: appState.showTabBarView) { _, showTabBar in
            if !showTabBar {
                Task {
                    await checkUserStatus()
                }
            }
        }
    }
    
    enum Event: LoggableEvent {
        case alpha, beta, gamma, delta
        
        var eventName: String {
            switch self {
            case .alpha:
                return "Event_Alpha"
            case .beta:
                return "Event_Beta"
            case .gamma:
                return "Event_Gamma"
            case .delta:
                return "Event_Delta"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .alpha, .beta:
                return [
                    "aaa": true,
                    "bbb": 123
                ]
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .alpha:
                return .info
            case .beta:
                return .analytic
            case .gamma:
                return .warning
            case .delta:
                return .severe
            }
        }
    }
    
    private func checkUserStatus() async {
        if let user = authManager.userAuth {
            // User is Authenticated
            print("User already authenticated", user.uid)
            
            do {
                try await userManager.logIn(userAuth: user, isNewUser: false)
            } catch {
                print("Failed to log into auth for existing user: \(error)")
                try? await Task.sleep(for: .seconds(1))
                await checkUserStatus()
            }
        } else {
            // User is not Authenticated
            do {
                let result = try await authManager.signInAnonymously()
                
                // Log into application
                print("Sign in anonymous success.", result.user.uid)
                
                // Log in
                try await userManager.logIn(userAuth: result.user, isNewUser: result.isNewUser)
                
            } catch {
                print("Failed to sign in anonymously and log in: \(error)")
                try? await Task.sleep(for: .seconds(1))
                await checkUserStatus()
            }
        }
    }
}

#Preview {
    AppView(appState: AppState(showTabBarView: true))
        .environment(AuthManager(service: MockAuthService(user: .mock())))
        .environment(UserManager(services: MockUserServices(user: .mock)))
}

#Preview {
    AppView(appState: AppState(showTabBarView: false))
        .environment(AuthManager(service: MockAuthService(user: nil)))
        .environment(UserManager(services: MockUserServices(user: nil)))
}
