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
                .environment(delegate.dependencies.chatManager)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    var dependencies: Dependencies!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        #if MOCK
        dependencies = Dependencies(config: .mock(isSignedIn: true))
        #elseif DEV
        dependencies = Dependencies(config: .dev)
        #else
        dependencies = Dependencies(config: .prod)
        #endif
       
        return true
    }
}

enum BuildConfiguration {
    case mock(isSignedIn: Bool), dev, prod
}

@MainActor
struct Dependencies {
    var authManager: AuthManager
    var userManager: UserManager
    var aiManager: AIManager
    var avatarManager: AvatarManager
    var chatManager: ChatManager
    
    init(config: BuildConfiguration) {
        
        switch config {
        case .mock(isSignedIn: let isSignedIn):
            self.authManager = AuthManager(service: MockAuthService(user: isSignedIn ? .mock() : nil))
            self.userManager = UserManager(services: MockUserServices(user: isSignedIn ? .mock : nil))
            self.aiManager = AIManager(imageGenerationService: MockAIService(), textGenerationService: MockAIService())
            self.avatarManager = AvatarManager(service: MockRemoteAvatarService(), local: MockLocalAvatarPersistence())
            self.chatManager = ChatManager(service: MockChatService())
        case .dev:
            self.authManager = AuthManager(service: FirebaseAuthService())
            self.userManager = UserManager(services: ProductionUserServices())
            self.aiManager = AIManager(imageGenerationService: AppleAIService(), textGenerationService: FoundationModelService())
            self.avatarManager = AvatarManager(service: FirebaseAvatarService(imageUploadService: AppwriteImageUploadService()), local: SwiftDataLocalAvatarPersistence())
            self.chatManager = ChatManager(service: FirebaseChatService())
        case .prod:
            self.authManager = AuthManager(service: FirebaseAuthService())
            self.userManager = UserManager(services: ProductionUserServices())
            self.aiManager = AIManager(imageGenerationService: AppleAIService(), textGenerationService: FoundationModelService())
            self.avatarManager = AvatarManager(service: FirebaseAvatarService(imageUploadService: AppwriteImageUploadService()), local: SwiftDataLocalAvatarPersistence())
            self.chatManager = ChatManager(service: FirebaseChatService())
            print("This is production")
        }
    }
}

extension View {
    func previewEnvironment(isSignedIn: Bool = true) -> some View {
        self
            .environment(AIManager(imageGenerationService: MockAIService(), textGenerationService: MockAIService()))
            .environment(AuthManager(service: MockAuthService(user: isSignedIn ? .mock() : nil)))
            .environment(AvatarManager(service: MockRemoteAvatarService(), local: MockLocalAvatarPersistence()))
            .environment(UserManager(services: MockUserServices(user: isSignedIn ? .mock : nil)))
            .environment(ChatManager(service: MockChatService()))
            .environment(AppState())
    }
}
