//
//  OnboardingCompletedView.swift
//  AIChat
//
//  Created by Aman on 07/01/26.
//

import SwiftUI

struct OnboardingCompletedView: View {
    @Environment(AppState.self) private var root
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
            .safeAreaInset(edge: .bottom, content: {
               ctaButton
            })
            .padding(24)
        }
    }
    
    private var ctaButton: some View {
        Button {
            onFinishButtonPressed()
        } label: {
            ZStack {
                if isCompletingProfileSetup {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Finish")
                }
            }
            .callToActionButton()
        }
        .disabled(isCompletingProfileSetup)
    }
    
    private func onFinishButtonPressed() {
        isCompletingProfileSetup = true
        Task {
            try await Task.sleep(for: .seconds(3))
            isCompletingProfileSetup = false
            root.updateViewState(showTabBarView: true)
        }
    }
}

#Preview {
    OnboardingCompletedView()
        .environment(AppState())
}
