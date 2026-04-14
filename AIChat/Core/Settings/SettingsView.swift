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
    @Environment(\.authService) private var authService
    @Environment(AppState.self) private var appState
    
    @State private var isPremium: Bool = true
    @State private var isAnonymousUser = false
    @State private var showCreateAccountView = false
    @State private var showAlert: AnyAppAlert?
    
    var body: some View {
        NavigationStack {
            List {
                accountSection
                purchaseSection
                applicationSection
            }
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
        }
    }
    
    private var accountSection: some View {
        Section {
            if isAnonymousUser {
                Text("Save & back-up account")
                    .rowFormatting()
                    .anyButton(.highlight) {
                        onCreateAccountPressed()
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
                    
                }
                .removeListRowFormatting()
        } header: {
            Text("Application")
        } footer: {
            Text("Created by Aman Singh")
        }
    }
    
    func onSignOutButtonPressed() {
        Task {
            do {
                try authService.signOut()
                await dismissScreen()
            } catch {
                showAlert = AnyAppAlert(error: error)
            }
        }
    }
    
    func dismissScreen() async {
        dismiss()
        try? await Task.sleep(for: .seconds(1))
        appState.updateViewState(showTabBarView: false)
    }
    
    func onDeleteButtonPressed() {
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
        Task {
            do {
                try await authService.deleteAccount()
                await dismissScreen()
            } catch {
                showAlert = AnyAppAlert(error: error)
            }
        }
    }
    
    func onCreateAccountPressed() {
        showCreateAccountView = true
    }
    
    private func setAnonymousAccountStatus() {
        isAnonymousUser = authService.getAuthenticatedUser()?.isAnonymous == true
    }
}

fileprivate
extension View {
    func rowFormatting() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 16)
            .background(Color(uiColor: .systemBackground))
    }
}

#Preview {
    SettingsView()
        .environment(AppState())
}
