//
//  ExploreView.swift
//  AIChat
//
//  Created by Aman on 07/01/26.
//

import SwiftUI

struct ExploreView: View {
    @State private var featuredAvatar = AvatarModel.mocks
    @State private var categories: [CharacterOption] = CharacterOption.allCases
    
    var body: some View {
        NavigationStack {
            List {
                featuredSection
                categorySection
            }
            .navigationTitle("Explore")
        }
    }
    
    private var featuredSection: some View {
        Section {
            ZStack {
                CarouselView(items: featuredAvatar) { avatar in
                    HeroCellView(
                        title: avatar.name,
                        subtitle: avatar.description,
                        imageName: avatar.profileImageName
                    )
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
                        ForEach(categories, id: \.self){ category in
                            CategoryCellView(
                                title: category.rawValue,
                                imageName: Constants.randomImage,
                                font: .body,
                                cornerRadius: 16
                            )
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
}

#Preview {
    ExploreView()
}
