//
//  CategoryListView.swift
//  AIChat
//
//  Created by Aman on 10/04/26.
//

import SwiftUI

struct CategoryListView: View {
    @State private var avatars: [AvatarModel] = AvatarModel.mocks
    
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
            
            ForEach(avatars, id: \.self) { avatar in
                CustomListCellView(
                    imageName: avatar.profileImageName,
                    title: avatar.name,
                    subtitle: avatar.description
                )
                .removeListRowFormatting()
            }
        }
        .ignoresSafeArea()
        .listStyle(PlainListStyle())
    }
}

#Preview {
    CategoryListView()
}
