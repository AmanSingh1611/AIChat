//
//  AppViewBuilder.swift
//  AIChat
//
//  Created by Aman on 06/01/26.
//

import SwiftUI

struct AppViewBuilder<TabBarView: View, OnboardingView: View>: View {
    var showTabBarView: Bool
    
    @ViewBuilder var tabbarView: TabBarView
    @ViewBuilder var onboardingView: OnboardingView
    
    var body: some View {
        ZStack {
            if showTabBarView {
                tabbarView
                    .transition(.move(edge: .trailing))
            } else {
               onboardingView
                    .transition(.move(edge: .leading))
            }
        }
        .animation(.smooth, value: showTabBarView)
    }
}

private struct PreviewAppViewBuilder: View {
    @State private var showTabBarView = false
    
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
        .onTapGesture {
            showTabBarView.toggle()
        }
    }
}

#Preview {
    PreviewAppViewBuilder()
}
