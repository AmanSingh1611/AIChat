//
//  OnboardingCompletedView.swift
//  AIChat
//
//  Created by Aman on 07/01/26.
//

import SwiftUI

struct OnboardingCompletedView: View {
    @Environment(AppState.self) private var root
    @Environment(UserManager.self) private var userManager
    
    @State private var isCompletingProfileSetup: Bool = false
    var selectedColor: Color = .orange
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                Text("Setup Complete!")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .foregroundStyle(selectedColor)
                
                Text("We've setup your profile and you're ready to start chatting.")
                    .font(.title)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            }
            .frame(maxHeight: .infinity)
            .safeAreaInset(
                edge: .bottom,
                content: {
                    AsyncCallToActionButton(
                        title: "Finish",
                        isLoading: isCompletingProfileSetup,
                        action: onFinishButtonPressed
                    )
            })
            .padding(24)
        }
    }
    
    private func onFinishButtonPressed() {
        isCompletingProfileSetup = true
        Task {
            let hex = selectedColor.toHex()
            try await userManager.markOnboardingCompleteForCurrentuser(profileColorHex: hex ?? "#FF5757")
            
            // Dismiss Screen
            isCompletingProfileSetup = false
            root.updateViewState(showTabBarView: true)
        }
    }
}

#Preview {
    OnboardingCompletedView()
        .environment(AppState())
        .environment(UserManager(service: MockUserService()))
}
