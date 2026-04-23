//
//  CreateAvatarView.swift
//  AIChat
//
//  Created by Aman on 24/03/26.
//

import SwiftUI

struct CreateAvatarView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(AIManager.self) private var aiManager
    @Environment(AuthManager.self) private var authManager
    @Environment(AvatarManager.self) private var avatarManager
    
    @State private var characterOption: CharacterOption = .default
    @State private var characterAction: CharacterAction = .default
    @State private var characterLocation: CharacterLocation = .default
    @State private var avatarName: String = ""
    
    @State private var isGeneratingImage: Bool = false
    @State private var generatedImage: UIImage?
    
    @State private var isSaving: Bool = false
    @State private var showAlert: AnyAppAlert?
            
    var body: some View {
        NavigationStack {
            List {
                nameSection
                attributesSection
                imageSection
                saveSection
            }
            .navigationTitle("Create Avatar")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    backButton
                }
            }
            .showCustomAlert(alert: $showAlert)
        }
    }
    
    private var backButton: some View {
        Image(systemName: "xmark")
            .font(.title2)
            .fontWeight(.semibold)
            .anyButton(.plain) {
                onBackButtonPressed()
            }
    }
    
    private var nameSection: some View {
        Section {
            TextField("Player 1", text: $avatarName)
        } header: {
            Text("Name your avatar *")
        }
    }
    
    private var attributesSection: some View {
        Section {
            Picker(selection: $characterOption) {
                ForEach(CharacterOption.allCases, id: \.self) { option in
                    Text(option.rawValue.capitalized)
                        .tag(option)
                }
            } label: {
                Text("is a..")
            }
            
            Picker(selection: $characterAction) {
                ForEach(CharacterAction.allCases, id: \.self) { action in
                    Text(action.rawValue.capitalized)
                        .tag(action)
                }
            } label: {
                Text("that is..")
            }
            
            Picker(selection: $characterLocation) {
                ForEach(CharacterLocation.allCases, id: \.self) { location in
                    Text(location.rawValue.capitalized)
                        .tag(location)
                }
            } label: {
                Text("in the..")
            }
        } header: {
            Text("Attributes")
        }
    }
    
    private var imageSection: some View {
        Section {
            HStack(alignment: .top, spacing: 8) {
                ZStack {
                    Text("Genetate Avatar")
                        .underline()
                        .foregroundStyle(.accent)
                        .anyButton(.plain) {
                            onGenerateImagePressed()
                        }
                        .opacity(isGeneratingImage ? 0 : 1)
                    
                    ProgressView()
                        .tint(.accent)
                        .opacity(isGeneratingImage ? 1 : 0)
                }
                .disabled(isGeneratingImage || avatarName.isEmpty)
                
                Circle()
                    .fill(.secondary.opacity(0.3))
                    .overlay {
                        if let generatedImage {
                            Image(uiImage: generatedImage)
                                .resizable()
                                .scaledToFit()
                        }
                    }
                    .clipShape(Circle())
                
            }
        }
        .padding()
        .removeListRowFormatting()
    }
    
    private var saveSection: some View {
        Section {
            AsyncCallToActionButton(
                title: "Save",
                isLoading: isSaving,
                action: onSavePressed
            )
            .removeListRowFormatting()
            .padding()
            .disabled(generatedImage == nil)
        }
    }
    
    private func onBackButtonPressed() {
        dismiss()
    }
    
    private func onGenerateImagePressed() {
        isGeneratingImage = true
        
        Task {
            do {
                let prompt = AvatarDescriptionBuilder(
                    characterOption: characterOption,
                    characterAction: characterAction,
                    characterLocation: characterLocation
                )
                .characterDescription

                generatedImage = try await aiManager.generateImage(input: prompt)
                
            } catch {
                print("Error generating image: \(error)")
            }
            
            isGeneratingImage = false
        }
    }
    
    private func onSavePressed() {
        guard let generatedImage else { return }
        
        isSaving = true
        
        Task {
            do {
                
                let authorId = try authManager.getAuthId()
                
                try TextValidationHelper.checkIfTextIsValid(text: avatarName, minimumCharacterCount: 3)
                
                let avatar = AvatarModel(
                    avatarId: UUID().uuidString,
                    name: avatarName,
                    characterOption: characterOption,
                    characterAction: characterAction,
                    characterLocation: characterLocation,
                    profileImageName: nil,
                    authorId: authorId,
                    dateCreated: .now,
                    clickCount: 0
                )
                
                try await avatarManager.createAvatar(avatar: avatar, image: generatedImage)
                
                // Dismiss screen code
                dismiss()
            } catch let error {
                showAlert = AnyAppAlert(error: error)
            }
            
            isSaving = false
        }
    }
}

#Preview {
    CreateAvatarView()
        .environment(AIManager(service: MockAIService()))
        .environment(AuthManager(service: MockAuthService(user: .mock())))
        .environment(AvatarManager(service: MockRemoteAvatarService(), local: MockLocalAvatarPersistance()))
}
