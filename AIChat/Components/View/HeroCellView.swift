//
//  HeroCellView.swift
//  AIChat
//
//  Created by Aman on 12/02/26.
//

import SwiftUI

struct HeroCellView: View {
    var title: String? = "This is some title"
    var subtitle: String? = "This is some subtitle that goes here."
    var imageName: String? = Constants.randomImage
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if let imageName {
                ImageLoaderView(urlString: imageName)
            } else {
                Rectangle()
                    .fill(.accent)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                if let title {
                    Text(title)
                        .font(.headline)
                }

                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                }
            }
            .foregroundStyle(.white)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(colors: [
                    Color.black.opacity(0),
                    Color.black.opacity(0.3),
                    Color.black.opacity(0.4)
                ], startPoint: .top, endPoint: .bottom)
            )
        }
        .cornerRadius(16)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 12) {
            HeroCellView()
                .frame(width: 300, height: 200)
            
            HeroCellView(imageName: nil)
                .frame(width: 300, height: 200)
            
            HeroCellView(title: nil)
                .frame(width: 300, height: 200)
            
            HeroCellView(subtitle: nil)
                .frame(width: 300, height: 200)
            
            HeroCellView()
                .frame(width: 100, height: 500)
        }
        .frame(maxWidth: .infinity)
    }
}
