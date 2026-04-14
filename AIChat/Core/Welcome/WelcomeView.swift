//
//  WelcomeView.swift
//  AIChat
//
//  Created by Aman on 07/01/26.
//

import SwiftUI

struct WelcomeView: View {
    @Environment(AppState.self) private var root
    @State var randomImage = Constants.randomImage
    @State private var showSignInView = false
    
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
        .sheet(isPresented: $showSignInView) {
            CreateAccountView(
                title: "Sign In",
                subTitle: "Connect to an existing account",
                onDidSignIn: { isNewUser in
                    handleDidSignIn(isNewUser: isNewUser)
                }
            )
            .presentationDetents([.medium])
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
                OnboardingIntroView()
            } label: {
                Text("Get Started")
                    .callToActionButton()
            }
            .padding(16)
            
            Text("Already have an account? Sign In!")
                .underline()
                .font(.body)
                .padding(10)
                .tappablebackground()
                .onTapGesture {
                    onSignInPressed()
                }
        }
    }
    
    private func handleDidSignIn(isNewUser: Bool) {
        if isNewUser {
            // Do nothing handle user onboarding
        } else {
            root.updateViewState(showTabBarView: true)
        }
    }
    
    private func onSignInPressed() {
        showSignInView = true
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
        .environment(AppState())
}
