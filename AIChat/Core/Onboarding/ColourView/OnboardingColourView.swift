//
//  OnboardingColourView.swift
//  AIChat
//
//  Created by Aman on 20/01/26.
//

import SwiftUI

struct OnboardingColourView: View {
    let profileColors: [Color] = [.red, .green, .yellow, .mint, .purple, .cyan, .orange, .brown, .indigo]
    
    @State private var selectedColor: Color?
    
    var body: some View {
        ScrollView {
            colorGrid
            .padding(.horizontal, 24)
        }
        .safeAreaInset(edge: .bottom, alignment: .center, content: {
            if selectedColor != nil {
                ZStack {
                    ctaButton
                        .transition(AnyTransition.move(edge: .bottom))
                }
                .padding(24)
                .background(Color(uiColor: .systemBackground))
            }
        })
        .animation(.smooth, value: selectedColor)
    }
    
    private var colorGrid: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3),
            alignment: .center,
            spacing: 16,
            pinnedViews: [.sectionHeaders],
            content: {
                Section(content: {
                    ForEach( profileColors, id: \.self) { color in
                        Circle()
                            .fill(.accent)
                            .overlay(content: {
                                color
                                    .clipShape(Circle())
                                    .padding(selectedColor == color ? 10 : 0)
                            })
                            .onTapGesture {
                                selectedColor = color
                            }
                    }
                }, header: {
                    Text("Select a Profile Colour")
                        .font(.headline)
                })
            }
        )
    }
    
    private var ctaButton: some View {
        ZStack {
            NavigationLink {
                OnboardingCompletedView()
            } label: {
                Text("Continue")
                    .callToActionButton()
            }
        }
    }
}

#Preview {
    NavigationStack {
        OnboardingColourView()
    }
}
