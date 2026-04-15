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
        } else {
            // User is not Authenticated
            do {
                let result = try await authManager.signInAnonymously()
                print("Sign in anonymous success.", result.user.uid)
            } catch {
                print(error)
            }
        }
    }
}

#Preview {
    AppView(appState: AppState(showTabBarView: true))
}

#Preview {
    AppView(appState: AppState(showTabBarView: false))
}
