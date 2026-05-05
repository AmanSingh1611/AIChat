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
    @Environment(LogManager.self) private var logManager
    
    @State private var isCompletingProfileSetup: Bool = false
    @State private var showAlert: AnyAppAlert?
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
            .toolbar(.hidden, for: .navigationBar)
            .screenAppearAnalytics(name: "OnboardingCompletedView")
            .showCustomAlert(alert: $showAlert)
        }
    }
    
    private func onFinishButtonPressed() {
        isCompletingProfileSetup = true
        logManager.trackEvent(event: Event.finishStart)
        
        Task {
            do {
                let hex = selectedColor.toHex()
                try await userManager.markOnboardingCompleteForCurrentuser(profileColorHex: hex)
                logManager.trackEvent(event: Event.finishSuccess(hex: hex))
                
                // dismiss screen
                isCompletingProfileSetup = false
                root.updateViewState(showTabBarView: true)
            } catch {
                showAlert = AnyAppAlert(error: error)
                logManager.trackEvent(event: Event.finishFail(error: error))
            }
        }
    }
    
    enum Event: LoggableEvent {
        case finishStart
        case finishSuccess(hex: String)
        case finishFail(error: Error)
        
        var eventName: String {
            switch self {
            case .finishStart:         return "OnboardingCompletedView_Finish_Start"
            case .finishSuccess:       return "OnboardingCompletedView_Finish_Success"
            case .finishFail:          return "OnboardingCompletedView_Finish_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .finishSuccess(hex: let hex):
                return [
                    "profile_color_hex": hex
                ]
            case .finishFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .finishFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}

#Preview {
    OnboardingCompletedView()
        .environment(AppState())
        .environment(UserManager(services: MockUserServices()))
}
