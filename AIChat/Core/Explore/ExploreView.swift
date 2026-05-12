//
//  ExploreView.swift
//  AIChat
//
//  Created by Aman on 07/01/26.
//

import SwiftUI

struct ExploreView: View {
    
    @Environment(AvatarManager.self) var avatarManager
    @Environment(LogManager.self) private var logManager
    @Environment(PushNotificationManager.self) var pushNotificationManager
    
    @State private var categories: [CharacterOption] = CharacterOption.allCases
    @State private var featuredAvatars: [AvatarModel] = []
    @State private var popularAvatars: [AvatarModel] = []
    @State private var isLoadingFeatured: Bool = true
    @State private var isLoadingPopular: Bool = true
    
    @State private var path: [NavigationPathOption] = []
    @State private var showDevSettings: Bool = false
    @State private var showNotificationButton: Bool = false
    @State private var showPushNotificationModal: Bool = false

    private var showDevSettingsButton: Bool {
        #if DEV || MOCK
        return true
        #else
        return false
        #endif
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                if featuredAvatars.isEmpty && popularAvatars.isEmpty {
                    ZStack {
                        if isLoadingPopular || isLoadingFeatured {
                            loadingIndicator
                        } else {
                            errorMessageView
                        }
                    }
                    .removeListRowFormatting()
                }
                
                if !featuredAvatars.isEmpty {
                    featuredSection
                }
                
                if !popularAvatars.isEmpty {
                    categorySection
                    popularSection
                }
            }
            .navigationTitle("Explore")
            .toolbar(content: {
                ToolbarItem(placement: .topBarLeading) {
                    if showDevSettingsButton {
                        devSettingsButton
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    if showNotificationButton {
                        pushNotificationButton
                    }
                }
            })
            .sheet(isPresented: $showDevSettings, content: {
                DevSettingsView()
            })
            .navigationDestinationForCoreModule(path: $path)
            .showModal(showModal: $showPushNotificationModal, content: {
                pushNotificationModal
            })
            .task {
                await loadFeaturedAvatars()
            }
            .task {
                await loadPopularAvatars()
            }
            .task {
                await handleShowPushNotificationButton()
            }
            .onFirstAppear {
                schedulePushNotifications()
            }
        }
    }
    private func schedulePushNotifications() {
        pushNotificationManager.schedulePushNotificationsForTheNextWeek()
    }
    
    private func handleShowPushNotificationButton() async {
        showNotificationButton = await pushNotificationManager.canRequestAuthorization()
    }
    
    private var pushNotificationButton: some View {
        Image(systemName: "bell.fill")
            .font(.headline)
            .padding(4)
            .tappablebackground()
            .foregroundStyle(.accent)
            .anyButton {
                onPushNotificationButtonPressed()
            }
    }
    
    private func onPushNotificationButtonPressed() {
        showPushNotificationModal = true
        logManager.trackEvent(event: Event.pushNotifsStart)
    }
    
    private func onEnablePushNotificationsPressed() {
        showPushNotificationModal = false
        
        Task {
            let isAuthorized = try await pushNotificationManager.requestAuthorization()
            logManager.trackEvent(event: Event.pushNotifsEnable(isAuthorized: isAuthorized))
            await handleShowPushNotificationButton()
        }
    }
    
    private func onCancelPushNotificationsPressed() {
        showPushNotificationModal = false
        logManager.trackEvent(event: Event.pushNotifsCancel)
    }
    
    private var pushNotificationModal: some View {
        CustomModalView(
            title: "Enable push notifications?",
            subtitle: "We'll send you reminders and updates!",
            primaryButtonTitle: "Enable",
            primaryButtonAction: {
                onEnablePushNotificationsPressed()
            },
            secondaryButtonTitle: "Cancel",
            secondaryButtonAction: {
                onCancelPushNotificationsPressed()
            }
        )
    }
    private var devSettingsButton: some View {
        Text("DEV")
            .anyButton(.press) {
                onDevSettingsPressed()
            }
    }
    
    private func onDevSettingsPressed() {
        showDevSettings = true
        logManager.trackEvent(event: Event.devSettingsPressed)
    }
    
    private func loadFeaturedAvatars() async {
        logManager.trackEvent(event: Event.loadFeaturedAvatarsStart)
        do {
            featuredAvatars = try await avatarManager.getFeaturedAvatars()
            logManager.trackEvent(event: Event.loadFeaturedAvatarsSuccess(count: featuredAvatars.count))
        } catch {
            logManager.trackEvent(event: Event.loadFeaturedAvatarsFail(error: error))
        }
        isLoadingFeatured = false
    }
    
    private func loadPopularAvatars() async {
        logManager.trackEvent(event: Event.loadPopularAvatarsStart)
        do {
            popularAvatars = try await avatarManager.getPopularAvatars()
            logManager.trackEvent(event: Event.loadPopularAvatarsSuccess(count: popularAvatars.count))
        } catch {
            logManager.trackEvent(event: Event.loadPopularAvatarsFail(error: error))
        }
        isLoadingPopular = false
    }
    
    private func onTryAgainPressed() {
        isLoadingPopular = true
        isLoadingFeatured = true
        logManager.trackEvent(event: Event.tryAgainPressed)
        
        Task {
            await loadFeaturedAvatars()
        }
        Task {
            await loadPopularAvatars()
        }
    }
    
    private var loadingIndicator: some View {
        ProgressView()
            .padding(40)
            .frame(maxWidth: .infinity)
    }
    
    private var errorMessageView: some View {
        VStack(alignment: .center, spacing: 10) {
            Text("Error")
                .font(.headline)
            
            Text("Please check your internet connection and try again.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Button("Try Again") {
                onTryAgainPressed()
            }
            .foregroundStyle(.blue)
        }
        .multilineTextAlignment(.center)
        .padding(40)
    }
    
    private var featuredSection: some View {
        Section {
            ZStack {
                CarouselView(items: featuredAvatars) { avatar in
                    HeroCellView(
                        title: avatar.name,
                        subtitle: avatar.description,
                        imageName: avatar.profileImageName
                    )
                    .anyButton {
                        onAvatarPressed(avatar: avatar)
                    }
                }
            }
            .removeListRowFormatting()
        } header: {
            Text("Featured Avatars")
        }
    }
    
    private var categorySection: some View {
        Section {
            ZStack {
                ScrollView(.horizontal) {
                    HStack(spacing: 12) {
                        ForEach(categories, id: \.self) { category in
                            let imageName = popularAvatars.first(where: { $0.characterOption == category})?.profileImageName
                            if let imageName {
                                CategoryCellView(
                                    title: category.plural.capitalized,
                                    imageName: imageName,
                                    font: .body,
                                    cornerRadius: 16
                                )
                                .anyButton {
                                    onCategoryPressed(category: category, imageName: imageName)
                                }
                            }
                        }
                    }
                    
                }
                .frame(height: 140)
                .scrollIndicators(.hidden)
                .scrollTargetLayout()
                .scrollTargetBehavior(.viewAligned)
            }
            .removeListRowFormatting()
        } header: {
            Text("Categories")
        }
    }
    
    private var popularSection: some View {
        Section {
            ForEach(popularAvatars, id: \.self) { avatar in
                CustomListCellView(imageName: avatar.profileImageName, title: avatar.name, subtitle: avatar.description)
                    .anyButton(.highlight, action: {
                        onAvatarPressed(avatar: avatar)
                    })
                    .removeListRowFormatting()
            }
        } header: {
            Text("Popular")
        }
    }
    
    private func onAvatarPressed(avatar: AvatarModel) {
        path.append(.chat(avatarId: avatar.avatarId, chat: nil))
        logManager.trackEvent(event: Event.avatarPressed(avatar: avatar))
    }
    
    private func onCategoryPressed(category: CharacterOption, imageName: String) {
        path.append(.category(category: category, imageName: imageName))
        logManager.trackEvent(event: Event.categoryPressed(category: category))
    }
    
    enum Event: LoggableEvent {
        case devSettingsPressed
        case tryAgainPressed
        case loadFeaturedAvatarsStart
        case loadFeaturedAvatarsSuccess(count: Int)
        case loadFeaturedAvatarsFail(error: Error)
        case loadPopularAvatarsStart
        case loadPopularAvatarsSuccess(count: Int)
        case loadPopularAvatarsFail(error: Error)
        case avatarPressed(avatar: AvatarModel)
        case categoryPressed(category: CharacterOption)
        case pushNotifsStart
        case pushNotifsEnable(isAuthorized: Bool)
        case pushNotifsCancel
        
        var eventName: String {
            switch self {
            case .devSettingsPressed:           return "ExploreView_DevSettings_Pressed"
            case .tryAgainPressed:              return "ExploreView_TryAgain_Pressed"
            case .loadFeaturedAvatarsStart:     return "ExploreView_LoadFeaturedAvatars_Start"
            case .loadFeaturedAvatarsSuccess:   return "ExploreView_LoadFeaturedAvatars_Success"
            case .loadFeaturedAvatarsFail:      return "ExploreView_LoadFeaturedAvatars_Fail"
            case .loadPopularAvatarsStart:      return "ExploreView_LoadPopularAvatars_Start"
            case .loadPopularAvatarsSuccess:    return "ExploreView_LoadPopularAvatars_Success"
            case .loadPopularAvatarsFail:       return "ExploreView_LoadPopularAvatars_Fail"
            case .avatarPressed:                return "ExploreView_Avatar_Pressed"
            case .categoryPressed:              return "ExploreView_Category_Pressed"
            case .pushNotifsStart:              return "ExploreView_PushNotifs_Start"
            case .pushNotifsEnable:             return "ExploreView_PushNotifs_Enable"
            case .pushNotifsCancel:             return "ExploreView_PushNotifs_Cancel"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .loadPopularAvatarsSuccess(count: let count), .loadFeaturedAvatarsSuccess(count: let count):
                return [
                    "avatars_count": count
                ]
            case .loadPopularAvatarsFail(error: let error), .loadFeaturedAvatarsFail(error: let error):
                return error.eventParameters
            case .avatarPressed(avatar: let avatar):
                return avatar.eventParameters
            case .categoryPressed(category: let category):
                return [
                    "category": category.rawValue
                ]
            case .pushNotifsEnable(isAuthorized: let isAuthorized):
                return [
                    "is_authorized": isAuthorized
                ]
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .loadPopularAvatarsFail, .loadFeaturedAvatarsFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}

#Preview("Has Data") {
    ExploreView()
        .environment(AvatarManager(service: MockRemoteAvatarService(), local: MockLocalAvatarPersistence()))
        .previewEnvironment()
}

#Preview("No Data") {
    ExploreView()
        .environment(AvatarManager(service: MockRemoteAvatarService(avatars: []), local: MockLocalAvatarPersistence()))
        .previewEnvironment()
}

#Preview("Slow Data") {
    ExploreView()
        .environment(AvatarManager(service: MockRemoteAvatarService(delay: 5), local: MockLocalAvatarPersistence()))
        .previewEnvironment()
}
