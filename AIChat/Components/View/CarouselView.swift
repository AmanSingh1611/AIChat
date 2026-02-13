//
//  CarouselView.swift
//  AIChat
//
//  Created by Aman on 12/02/26.
//

import SwiftUI

struct CarouselView<Content: View, T: Hashable>: View {
    let items: [T]
    @State private var selection: T?
    @ViewBuilder var content: (_ item: T) -> Content
    
    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 0) {
                ForEach(items, id: \.self) { item in
                    content(item)
                        .containerRelativeFrame(.horizontal, alignment: .center)
                        .scrollTransition(.interactive.threshold(.visible(0.95))) { content, phase in
                            content.scaleEffect(phase.isIdentity ? 1 : 0.9, anchor: .center)
                        }
                        .id(item)
                }
            }
        }
        .frame(height: 200)
        .scrollIndicators(.hidden)
        .scrollTargetLayout()
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: $selection)
        .onChange(of: items.count) { _, _ in
            updateSelectionIfNeeded()
        }
        .onAppear {
            updateSelectionIfNeeded()
        }
        
        HStack(spacing: 8) {
            ForEach(items, id: \.self) { item in
                Circle()
                    .fill(item == selection ? .accent : .secondary.opacity(0.5))
                    .frame(width: 8, height: 8)
                
            }
        }
        .animation(.linear, value: selection)
    }
    
    private func updateSelectionIfNeeded() {
        if selection == nil || selection == items.last {
            selection = items.first
        }
    }
}

#Preview {
    CarouselView(
        items: AvatarModel.mocks,
        content: { item in
            HeroCellView(
                title: item.name,
                subtitle: item.description,
                imageName: item.profileImageName
            )
    })
    .padding()
}
