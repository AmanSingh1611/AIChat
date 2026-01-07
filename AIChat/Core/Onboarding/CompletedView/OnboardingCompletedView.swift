//
//  OnboardingCompletedView.swift
//  AIChat
//
//  Created by Aman on 07/01/26.
//

import SwiftUI

struct OnboardingCompletedView: View {
    @Environment(AppState.self) private var root
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Welcome")
                    .frame(maxHeight: .infinity)
                
                Button {
                    onFinishButtonPressed()
                } label: {
                    Text("Finish")
                        .callToActionButton()
                }
                
            }
            .padding(16)
        }
    }
    
    private func onFinishButtonPressed() {
        root.updateViewState(showTabBarView: true)
    }
}

#Preview {
    OnboardingCompletedView()
        .environment(AppState())
}
