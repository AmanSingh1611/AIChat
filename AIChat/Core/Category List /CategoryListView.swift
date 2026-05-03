//
//  CategoryListView.swift
//  AIChat
//
//  Created by Aman on 10/04/26.
//

import SwiftUI

struct CategoryListView: View {
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(LogManager.self) private var logManager
    
    @State private var avatars: [AvatarModel] = []
    @Binding var path: [NavigationPathOption]
    @State private var showAlert: AnyAppAlert?
    @State private var isLoading: Bool = true
    
    var category: CharacterOption = .alien
    var imageName: String = Constants.randomImage
    
    var body: some View {
        List {
            CategoryCellView(
                title: category.plural.capitalized,
                imageName: imageName,
                font: .largeTitle,
                cornerRadius: 0
            )
            .removeListRowFormatting()
            
            if isLoading {
                ProgressView()
                    .padding(40)
                    .frame(maxWidth: .infinity)
                    .listRowSeparator(.hidden)
                    .removeListRowFormatting()
            } else if avatars.isEmpty {
                Text("No avatars found")
                    .foregroundStyle(.secondary)
                    .padding(40)
                    .foregroundStyle(.secondary)
                    .listRowSeparator(.hidden)
                    .removeListRowFormatting()
                    
            } else {
                ForEach(avatars, id: \.self) { avatar in
                    CustomListCellView(
                        imageName: avatar.profileImageName,
                        title: avatar.name,
                        subtitle: avatar.description
                    )
                    .anyButton(.highlight) {
                        onAvatarPressed(avatar: avatar)
                    }
                    .removeListRowFormatting()
                }
            }
        }
        .screenAppearAnalytics(name: "CategoryList")
        .ignoresSafeArea()
        .listStyle(PlainListStyle())
        .showCustomAlert(alert: $showAlert)
        .task {
            await loadAvatars()
        }
    }
    
    enum Event: LoggableEvent {
        case loadAvatarsStart
        case loadAvatarsSuccess
        case loadAvatarsFail(error: Error)
        case avatarPressed(avatar: AvatarModel)

        var eventName: String {
            switch self {
            case .loadAvatarsStart:          return "CategoryList_LoadAvatars_Start"
            case .loadAvatarsSuccess:        return "CategoryList_LoadAvatars_Success"
            case .loadAvatarsFail:           return "CategoryList_LoadAvatars_Fail"
            case .avatarPressed:             return "CategoryList_Avatar_Pressed"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .loadAvatarsFail(error: let error):
                return error.eventParameters
            case .avatarPressed(avatar: let avatar):
                return avatar.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .loadAvatarsFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
    
    private func loadAvatars() async {
        logManager.trackEvent(event: Event.loadAvatarsStart)
        do {
            avatars = try await avatarManager.getAvatarForCategory(category: category)
            logManager.trackEvent(event: Event.loadAvatarsSuccess)
        } catch {
            showAlert = AnyAppAlert(error: error)
            logManager.trackEvent(event: Event.loadAvatarsFail(error: error))
        }
        
        isLoading = false
    }
    
    private func onAvatarPressed(avatar: AvatarModel) {
        path.append(.chat(avatarId: avatar.avatarId, chat: nil))
        logManager.trackEvent(event: Event.avatarPressed(avatar: avatar))
    }
}

#Preview("Has Data") {
    @Previewable @State var path: [NavigationPathOption] = []
    CategoryListView(path: $path)
        .environment(AvatarManager(service: MockRemoteAvatarService(), local: MockLocalAvatarPersistence()))
}

#Preview("No Data") {
    @Previewable @State var path: [NavigationPathOption] = []
    CategoryListView(path: $path)
        .environment(AvatarManager(service: MockRemoteAvatarService(avatars: []), local: MockLocalAvatarPersistence()))
}

#Preview("Slow Data") {
    @Previewable @State var path: [NavigationPathOption] = []
    CategoryListView(path: $path)
        .environment(AvatarManager(service: MockRemoteAvatarService(delay: 10), local: MockLocalAvatarPersistence()))
}

#Preview("Error Loading Data") {
    @Previewable @State var path: [NavigationPathOption] = []
    CategoryListView(path: $path)
        .environment(AvatarManager(service: MockRemoteAvatarService(delay: 4, showError: true), local: MockLocalAvatarPersistence()))
}
