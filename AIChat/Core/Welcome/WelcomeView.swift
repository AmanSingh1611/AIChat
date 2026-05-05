//
//  WelcomeView.swift
//  AIChat
//
//  Created by Aman on 07/01/26.
//

import SwiftUI

struct WelcomeView: View {
    @Environment(AppState.self) private var root
    @Environment(LogManager.self) private var logManager
    
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
        .screenAppearAnalytics(name: "WelcomeView")
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
        logManager.trackEvent(event: Event.didSignIn(isNewUser: isNewUser))
        
        if isNewUser {
            // Do nothing handle user onboarding
        } else {
            root.updateViewState(showTabBarView: true)
        }
    }
    
    private func onSignInPressed() {
        showSignInView = true
        logManager.trackEvent(event: Event.signInPressed)
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
    
    enum Event: LoggableEvent {
        case didSignIn(isNewUser: Bool)
        case signInPressed
        
        var eventName: String {
            switch self {
            case .didSignIn:          return "WelcomeView_DidSignIn"
            case .signInPressed:      return "WelcomeView_SignIn_Pressed"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .didSignIn(isNewUser: let isNewUser):
                return [
                    "is_new_user": isNewUser
                ]
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            default:
                return .analytic
            }
        }
    }
}

#Preview {
    WelcomeView()
        .environment(AppState())
}
