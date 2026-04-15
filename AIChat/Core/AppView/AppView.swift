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
        .onChange(of: appState.showTabBarView) { _, showTabBar in
            if !showTabBar {
                Task {
                    await checkUserStatus()
                }
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
                try? await Task.sleep(for: .seconds(5))
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
                try? await Task.sleep(for: .seconds(5))
                await checkUserStatus()
            }
        }
    }
}

#Preview {
    AppView(appState: AppState(showTabBarView: true))
        .environment(AuthManager(service: MockAuthService(user: .mock())))
        .environment(UserManager(service: MockUserService(user: .mock)))
}

#Preview {
    AppView(appState: AppState(showTabBarView: false))
        .environment(AuthManager(service: MockAuthService(user: nil)))
        .environment(UserManager(service: MockUserService(user: nil)))
}
