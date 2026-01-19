//
//  WelcomeView.swift
//  AIChat
//
//  Created by Aman on 07/01/26.
//

import SwiftUI

struct WelcomeView: View {
    @State var randomImage = Constants.randomImage
    var body: some View {
        NavigationStack {
            VStack {
                ImageLoaderView(urlString: randomImage)
                    .ignoresSafeArea()
                
                titleSection
                    .padding(.top, 26)
                
                ctaButtons
                    .padding(16)
                
                policyLinks
            }
        }
    }
    
    private var titleSection: some View {
        VStack(spacing: 8) {
            Text("AI Chat ")
                .font(.largeTitle)
                .fontWeight(.semibold)
        }
    }
    
    private var ctaButtons: some View {
        VStack(spacing: 8) {
            NavigationLink {
                OnboardingCompletedView()
            } label: {
                Text("Get Started")
                    .callToActionButton()
            }
            .padding(16)
            
            Text("Already have an account? Sign In!")
                .underline()
                .font(.body)
                .padding(10)
                .tapablebackground()
                .onTapGesture {
                    
                }
        }
    }
    
    private var policyLinks: some View {
        HStack(spacing: 8) {
            Link(destination: URL(string: Constants.termsAndServicesLink)!) {
                Text("Terms of Service")
            }
            
            Circle()
                .fill(.accent)
                .frame(width: 4, height: 4)
            
            Link(destination: URL(string: Constants.privacyPolicyLink)!) {
                Text("Privacy Policy")
            }
        }
    }
    
}

#Preview {
    WelcomeView()
}
