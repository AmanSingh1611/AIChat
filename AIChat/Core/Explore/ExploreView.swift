//
//  ExploreView.swift
//  AIChat
//
//  Created by Aman on 07/01/26.
//

import SwiftUI

struct ExploreView: View {
    let avatar = AvatarModel.mock
    
    var body: some View {
        NavigationStack {
            HeroCellView(
                title: avatar.name,
                subtitle: avatar.description,
                imageName: avatar.profileImageName
            )
            .frame(height: 200)
            .navigationTitle("Explore")
        }
    }
}

#Preview {
    ExploreView()
}
