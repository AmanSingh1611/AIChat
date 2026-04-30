//
//  CategoryListView.swift
//  AIChat
//
//  Created by Aman on 10/04/26.
//

import SwiftUI

struct CategoryListView: View {
    @Environment(AvatarManager.self) private var avatarManager
    
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
                    .removeListRowFormatting()
            } else if avatars.isEmpty {
                Text("No avatars found")
                    .foregroundStyle(.secondary)
                    .padding(40)
                    .foregroundStyle(.secondary)
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
        .ignoresSafeArea()
        .listStyle(PlainListStyle())
        .showCustomAlert(alert: $showAlert)
        .task {
            await loadAvatars()
        }
    }
    
    private func loadAvatars() async {
        do {
            avatars = try await avatarManager.getAvatarForCategory(category: category)
        } catch let error {
            showAlert = AnyAppAlert(error: error)
        }
        isLoading = false
    }
    
    private func onAvatarPressed(avatar: AvatarModel) {
        path.append(.chat(avatarId: avatar.avatarId, chat: nil))
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
