//
//  OnboardingIntroView.swift
//  AIChat
//
//  Created by Aman on 19/01/26.
//

import SwiftUI

struct OnboardingIntroView: View {
    var body: some View {
        VStack {
            Text(
                 """
                 Make your own \(avatarsText) and chat with them!
                 
                 Have \(realConversationsText) with AI generated responses.
                 """
            )
            .padding(.horizontal, 10)
            .frame(maxHeight: .infinity)
            
            ctaButtons
        }
        .font(.title3)
        .padding(24)
    }
    
    private var avatarsText: AttributedString {
        var text = AttributedString("avatars")
        text.foregroundColor = .accent
        text.font = .title3.weight(.semibold)
        return text
    }
    
    private var realConversationsText: AttributedString {
        var text = AttributedString("real conversations")
        text.foregroundColor = .accent
        text.font = .title3.weight(.semibold)
        return text
    }
    
    private var ctaButtons: some View {
        VStack(spacing: 8) {
            NavigationLink {
                OnboardingColourView()
            } label: {
                Text("Get Started")
                    .callToActionButton()
            }
            .padding(16)
        }
    }
}

#Preview {
    NavigationStack {
        OnboardingIntroView()
    }
}
