//
//  AppView.swift
//  AIChat
//
//  Created by Aman on 06/01/26.
//

import SwiftUI

struct AppView: View {
    @AppStorage("showTabbarView") var showTabBarView: Bool = false
    
    var body: some View {
        AppViewBuilder(
            showTabBarView: showTabBarView,
            tabbarView: {
                ZStack {
                    Color.red.ignoresSafeArea()
                    Text("TabBarView")
                }
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
