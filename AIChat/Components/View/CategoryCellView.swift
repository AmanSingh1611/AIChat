//
//  CategoryCellView.swift
//  AIChat
//
//  Created by Aman on 13/02/26.
//

import SwiftUI

struct CategoryCellView: View {
    var title = "Alien"
    var imageName = Constants.randomImage
    var font: Font = .title2
    var cornerRadius: CGFloat = 16
    
    var body: some View {
        ImageLoaderView(urlString: imageName)
            .aspectRatio(1, contentMode: .fit)
            .overlay(alignment: .bottomLeading) {
                Text(title)
                    .foregroundStyle(.white)
                    .font(font)
                    .fontWeight(.semibold)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .adddingGradientBackgroundForText()
                    .lineLimit(1)
                    .minimumScaleFactor(0.3)
                    
            }
            .cornerRadius(cornerRadius)
    }
}

#Preview {
    CategoryCellView()
        .frame(width: 150)
}
