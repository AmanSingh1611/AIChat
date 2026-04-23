//
//  AIChatApp.swift
//  AIChat
//
//  Created by Aman on 05/01/26.
//

import SwiftUI
import FirebaseCore

@main
struct AIChatApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            AppView()
                .environment(delegate.dependencies.authManager)
                .environment(delegate.dependencies.userManager)
                .environment(delegate.dependencies.aiManager)
                .environment(delegate.dependencies.avatarManager)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    var dependencies: Dependencies!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        dependencies = Dependencies()
        return true
    }
}

@MainActor
struct Dependencies {
    var authManager: AuthManager
    var userManager: UserManager
    var aiManager: AIManager
    var avatarManager: AvatarManager
    
    init() {
        self.authManager = AuthManager(service: FirebaseAuthService())
        self.userManager = UserManager(services: ProductionUserServices())
        self.aiManager = AIManager(service: AppleAIService())
        self.avatarManager = AvatarManager(service: FirebaseAvatarService(), local: SwiftDataLocalAvatarPersistence())
    }
}

extension View {
    func previewEnvironment(isSignedIn: Bool = true) -> some View {
        self
            .environment(AIManager(service: MockAIService()))
            .environment(AuthManager(service: MockAuthService(user: isSignedIn ? .mock() : nil)))
            .environment(AvatarManager(service: MockRemoteAvatarService(), local: MockLocalAvatarPersistence()))
            .environment(UserManager(services: MockUserServices(user: isSignedIn ? .mock : nil)))
            .environment(AppState())
    }
}
