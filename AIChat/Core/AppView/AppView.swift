//
//  AppView.swift
//  AIChat
//
//  Created by Aman on 06/01/26.
//

import SwiftUI

struct AppView: View {
    @AppStorage("showTabbarView") var showTabBarView: Bool = true
    
    var body: some View {
        AppViewBuilder(
            showTabBarView: showTabBarView,
            tabbarView: {
                TabBarView()
            },
            onboardingView: {
                ZStack {
                    Color.blue.ignoresSafeArea()
                    Text("OnboardingView")
                }
            }
        )
    }
}

#Preview {
    AppView()
}
