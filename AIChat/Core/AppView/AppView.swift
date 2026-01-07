//
//  AppView.swift
//  AIChat
//
//  Created by Aman on 06/01/26.
//

import SwiftUI

struct AppView: View {
    @State var appState: AppState = AppState()
    
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
    }
}

#Preview {
    AppView(appState: AppState(showTabBarView: true))
}

#Preview {
    AppView(appState: AppState(showTabBarView: false))
}
