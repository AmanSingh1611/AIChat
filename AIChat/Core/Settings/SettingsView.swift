//
//  SettingsView.swift
//  AIChat
//
//  Created by Aman on 07/01/26.
//

import SwiftUI
import SwiftfulUtilities

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthManager.self) private var authManager
    @Environment(AppState.self) private var appState
    @Environment(UserManager.self) private var userManager
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(ChatManager.self) private var chatManager
    @Environment(LogManager.self) private var logManager
    
    @State private var isPremium: Bool = true
    @State private var isAnonymousUser = false
    @State private var showCreateAccountView = false
    @State private var showAlert: AnyAppAlert?
    @State private var showRatingsModal: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                accountSection
                purchaseSection
                applicationSection
            }
            .lineLimit(1)
            .minimumScaleFactor(0.3)
            .navigationTitle("Settings")
            .sheet(isPresented: $showCreateAccountView, onDismiss: {
                setAnonymousAccountStatus()
            }, content: {
                CreateAccountView()
                    .presentationDetents([.medium])
            })
            .onAppear {
                setAnonymousAccountStatus()
            }
            .showCustomAlert(alert: $showAlert)
            .screenAppearAnalytics(name: "SettingsView")
            .showModal(showModal: $showRatingsModal) {
                ratingsModal
            }
        }
    }
    
    private var ratingsModal: some View {
        CustomModalView(
            title: "Are you enjoying AIChat?",
            subtitle: "We'd love to hear your feedback!",
            primaryButtonTitle: "Yes",
            primaryButtonAction: {
                onEnjoyingAppYesPressed()
            },
            secondaryButtonTitle: "No",
            secondaryButtonAction: {
                onEnjoyingAppNoPressed()
            }
        )
    }
    
    private var accountSection: some View {
        Section {
            if isAnonymousUser {
                Text("Save & back-up account")
                    .rowFormatting()
                    .anyButton(.highlight) {
                        onRatingsButtonPressed()
                    }
                    .removeListRowFormatting()
                   
            } else {
                Text("Sign Out")
                    .rowFormatting()
                    .anyButton(.highlight) {
                        onSignOutButtonPressed()
                    }
                    .removeListRowFormatting()
            }
            
            Text("Delete account")
                .foregroundStyle(.red)
                .rowFormatting()
                .anyButton(.highlight) {
                    onDeleteButtonPressed()
                }
                .removeListRowFormatting()
        } header: {
            Text("Account")
        }
    }
    
    private var purchaseSection: some View {
        Section {
            HStack(spacing: 8) {
                Text("Account Status: \(isPremium ? "PREMIUM" : "FREE")")
                
                Spacer(minLength: 0)
                
                if isPremium {
                    Text("MANAGE")
                        .badgeButton()
                }
            }
            .rowFormatting()
            .anyButton(.highlight, action: {
                
            })
            .disabled(!isPremium)
            .removeListRowFormatting()
        } header: {
            Text("Purchase")
        }
    }
    
    private var applicationSection: some View {
        Section {
            Text("Rate Us on App Store!")
                .foregroundStyle(.blue)
                .rowFormatting()
                .anyButton(.highlight) {
                    onRatingsButtonPressed()
                }
                .removeListRowFormatting()
            
            HStack(spacing: 8) {
                Text("App Version")
                Spacer(minLength: 0)
                Text(Utilities.appVersion ?? "")
                    .foregroundStyle(.secondary)
            }
            .rowFormatting()
            .removeListRowFormatting()
            
            HStack(spacing: 8) {
                Text("Build Number")
                Spacer(minLength: 0)
                Text(Utilities.buildNumber ?? "")
                    .foregroundStyle(.secondary)
            }
            .rowFormatting()
            .removeListRowFormatting()
            
            Text("Contact Us")
                .foregroundStyle(.blue)
                .rowFormatting()
                .anyButton(.highlight) {
                    onContactUsPressed()
                }
                .removeListRowFormatting()
        } header: {
            Text("Application")
        } footer: {
            Text("Created by Aman Singh")
        }
    }
    
    private func onContactUsPressed() {
        logManager.trackEvent(event: Event.contactUsPressed)
        let email = "aman16024375@gmail.com"
        let emailStr = "mailto:\(email)"
        
        guard let url = URL(string: emailStr), UIApplication.shared.canOpenURL(url) else {
            return
        }
        
        UIApplication.shared.open(url)
    }
    
    private func onRatingsButtonPressed() {
        logManager.trackEvent(event: Event.ratingsPressed)
        showRatingsModal = true
    }
    
    private func onEnjoyingAppYesPressed() {
        logManager.trackEvent(event: Event.ratingsYesPressed)
        showRatingsModal = false
        AppStoreRatingsHelper.requestRatingsReview()
    }
    
    private func onEnjoyingAppNoPressed() {
        logManager.trackEvent(event: Event.ratingsNoPressed)
        showRatingsModal = false
    }
    
    private func onSignOutButtonPressed() {
        logManager.trackEvent(event: Event.signOutStart)
        Task {
            do {
                try authManager.signOut()
                userManager.signOut()
                logManager.trackEvent(event: Event.signOutSuccess)
                
                await dismissScreen()
            } catch {
                showAlert = AnyAppAlert(error: error)
                logManager.trackEvent(event: Event.signOutFail(error: error))
            }
        }
    }
    
    func dismissScreen() async {
        dismiss()
        try? await Task.sleep(for: .seconds(1))
        appState.updateViewState(showTabBarView: false)
    }
    
    func onDeleteButtonPressed() {
        logManager.trackEvent(event: Event.deleteAccountStart)
        
        showAlert = AnyAppAlert(
            title: "Delete Account?",
            subtitle: "This action is permanent and cannot be undone.",
            buttons: {
                AnyView(
                    Button(
                        "Delete",
                        role: .destructive,
                        action: {
                            onDeleteAccountConfirmed()
                        }
                    )
                )
            }
        )
    }
    
    func onDeleteAccountConfirmed() {
        logManager.trackEvent(event: Event.deleteAccountStartConfirm)
        
        Task {
            do {
                let userId = try authManager.getAuthId()
                
                async let deleteAuth: () = authManager.deleteAccount()
                async let deleteUser: () = userManager.deleteCurrentUser()
                async let deleteAllChats: () = chatManager.deleteAllChatsForUser(userId: userId)
                async let deleteAvatars: () = avatarManager.removeAuthorIdFromAllUserAvatars(userId: userId)
                
                _ = try await (deleteAuth, deleteUser, deleteAvatars, deleteAllChats)
                logManager.deleteUserProfile()
                logManager.trackEvent(event: Event.deleteAccountSuccess)
                
                await dismissScreen()
            } catch {
                showAlert = AnyAppAlert(error: error)
                logManager.trackEvent(event: Event.deleteAccountFail(error: error))
            }
        }
    }
    
    func onCreateAccountPressed() {
        showCreateAccountView = true
        logManager.trackEvent(event: Event.createAccountPressed)
    }
    
    private func setAnonymousAccountStatus() {
        isAnonymousUser = authManager.userAuth?.isAnonymous == true
    }
    
    enum Event: LoggableEvent {
        case signOutStart
        case signOutSuccess
        case signOutFail(error: Error)
        case deleteAccountStart
        case deleteAccountStartConfirm
        case deleteAccountSuccess
        case deleteAccountFail(error: Error)
        case createAccountPressed
        case contactUsPressed
        case ratingsPressed
        case ratingsYesPressed
        case ratingsNoPressed
        
        var eventName: String {
            switch self {
            case .signOutStart:                 return "SettingsView_SignOut_Start"
            case .signOutSuccess:               return "SettingsView_SignOut_Success"
            case .signOutFail:                  return "SettingsView_SignOut_Fail"
            case .deleteAccountStart:           return "SettingsView_DeleteAccount_Start"
            case .deleteAccountStartConfirm:    return "SettingsView_DeleteAccount_StartConfirm"
            case .deleteAccountSuccess:         return "SettingsView_DeleteAccount_Success"
            case .deleteAccountFail:            return "SettingsView_DeleteAccount_Fail"
            case .createAccountPressed:         return "SettingsView_CreateAccount_Pressed"
            case .contactUsPressed:             return "SettingsView_ContactUs_Pressed"
            case .ratingsPressed:             return "SettingsView_Ratings_Pressed"
            case .ratingsYesPressed:            return "SettingsView_RatingsYes_Pressed"
            case .ratingsNoPressed:             return "SettingsView_RatingsNo_Pressed"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .signOutFail(error: let error), .deleteAccountFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .signOutFail, .deleteAccountFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}

private struct RowFormattingViewModifier: ViewModifier {
    
    @Environment(\.colorScheme) private var colorScheme
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(colorScheme.backgroundPrimary)
    }
}

fileprivate
extension View {
    func rowFormatting() -> some View {
        modifier(RowFormattingViewModifier())
    }
}

#Preview("No Auth") {
    SettingsView()
        .environment(AuthManager(service: MockAuthService(user: nil)))
        .environment(UserManager(services: MockUserServices(user: nil)))
        .environment(AppState())
        .previewEnvironment()
}

#Preview("Anonymous") {
    SettingsView()
        .environment(AuthManager(service: MockAuthService(user: UserAuthInfo.mock(isAnonymous: true))))
        .environment(UserManager(services: MockUserServices(user: .mock)))
        .environment(AppState())
        .previewEnvironment()
}

#Preview("Non Anonymous") {
    SettingsView()
        .environment(AuthManager(service: MockAuthService(user: UserAuthInfo.mock(isAnonymous: false))))
        .environment(UserManager(services: MockUserServices(user: .mock)))
        .environment(AppState())
        .previewEnvironment()
}
