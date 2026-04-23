//
//  ExploreView.swift
//  AIChat
//
//  Created by Aman on 07/01/26.
//

import SwiftUI

struct ExploreView: View {
    
    @Environment(AvatarManager.self) var avatarManager
    
    @State private var categories: [CharacterOption] = CharacterOption.allCases
    @State private var featuredAvatars: [AvatarModel] = []
    @State private var popularAvatars: [AvatarModel] = []
    @State private var isLoadingFeatured: Bool = true
    @State private var isLoadingPopular: Bool = true
    
    @State private var path: [NavigationPathOption] = []
    
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
            .navigationDestinationForCoreModule(path: $path)
            .task {
                await loadFeaturedAvatars()
            }
            .task {
                await loadPopularAvatars()
            }
        }
    }
    // Preview Avatars 9:18
    private func loadFeaturedAvatars() async {
        do {
            featuredAvatars = try await avatarManager.getFeaturedAvatars()
            isLoadingFeatured = false
        } catch {
            print("Error loading featured avatars \(error)")
        }
        
    }
    
    private func loadPopularAvatars() async {
        do {
            popularAvatars = try await avatarManager.getPopularAvatars()
            isLoadingPopular = false
        } catch {
            print("Error loading popular avatars \(error)")
        }
    }
    
    private func ontTryAgainPressed() {
        isLoadingPopular = true
        isLoadingFeatured = true
        
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
               ontTryAgainPressed()
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
        path.append(.chat(avatarId: avatar.avatarId))
    }
    
    private func onCategoryPressed(category: CharacterOption, imageName: String) {
        path.append(.category(category: category, imageName: Constants.randomImage))
    }
}

#Preview("Has Data") {
    ExploreView()
        .environment(AvatarManager(service: MockRemoteAvatarService(), local: MockLocalAvatarPersistance()))
}

#Preview("No Data") {
    ExploreView()
        .environment(AvatarManager(service: MockRemoteAvatarService(avatars: []), local: MockLocalAvatarPersistance()))
}

#Preview("Slow Data") {
    ExploreView()
        .environment(AvatarManager(service: MockRemoteAvatarService(delay: 5), local: MockLocalAvatarPersistance()))
}
