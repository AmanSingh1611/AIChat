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
    @Environment(LogManager.self) private var logManager
    
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
            .screenAppearAnalytics(name: "CreateAvatar")
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
        logManager.trackEvent(event: Event.backButtonPressed)
        dismiss()
    }
    
    private func onGenerateImagePressed() {
        isGeneratingImage = true
        logManager.trackEvent(event: Event.generateImageStart)
        
        Task {
            do {
                let avatarDescriptionBuilder = AvatarDescriptionBuilder(
                    characterOption: characterOption,
                    characterAction: characterAction,
                    characterLocation: characterLocation
                )
                
                let prompt = avatarDescriptionBuilder.characterDescription
                
                generatedImage = try await aiManager.generateImage(input: prompt)
                logManager.trackEvent(event: Event.generateImageSuccess(avatarDescriptionBuilder: avatarDescriptionBuilder))
                
            } catch {
                logManager.trackEvent(event: Event.generateImageFail(error: error))
            }
            
            isGeneratingImage = false
        }
    }
    
    private func onSavePressed() {
        logManager.trackEvent(event: Event.saveAvatarStart)
        guard let generatedImage else { return }
        
        isSaving = true
        
        Task {
            do {
                
                let authorId = try authManager.getAuthId()
                
                try TextValidationHelper.checkIfTextIsValid(text: avatarName, minimumCharacterCount: 3)
                
                let avatar = AvatarModel.newAvatar(
                    name: avatarName,
                    option: characterOption,
                    action: characterAction,
                    location: characterLocation,
                    authorId: authorId
                )
                
                try await avatarManager.createAvatar(avatar: avatar, image: generatedImage)
                logManager.trackEvent(event: Event.saveAvatarSuccess(avatar: avatar))
                
                // Dismiss screen code
                dismiss()
            } catch let error {
                showAlert = AnyAppAlert(error: error)
                logManager.trackEvent(event: Event.saveAvatarFail(error: error))
            }
            
            isSaving = false
        }
    }
    
    enum Event: LoggableEvent {
        case backButtonPressed
        case generateImageStart
        case generateImageSuccess(avatarDescriptionBuilder: AvatarDescriptionBuilder)
        case generateImageFail(error: Error)
        case saveAvatarStart
        case saveAvatarSuccess(avatar: AvatarModel)
        case saveAvatarFail(error: Error)

        var eventName: String {
            switch self {
            case .backButtonPressed:         return "CreateAvatarView_BackButton_Pressed"
            case .generateImageStart:        return "CreateAvatarView_GenImage_Start"
            case .generateImageSuccess:      return "CreateAvatarView_GenImage_Success"
            case .generateImageFail:         return "CreateAvatarView_GenImage_Fail"
            case .saveAvatarStart:           return "CreateAvatarView_SaveAvatar_Start"
            case .saveAvatarSuccess:         return "CreateAvatarView_SaveAvatar_Success"
            case .saveAvatarFail:            return "CreateAvatarView_SaveAvatar_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .generateImageSuccess(avatarDescriptionBuilder: let avatarDescriptionBuilder):
                return avatarDescriptionBuilder.eventParameters
            case .saveAvatarSuccess(avatar: let avatar):
                return avatar.eventParameters
            case .generateImageFail(error: let error), .saveAvatarFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .generateImageFail:
                return .severe
            case .saveAvatarFail:
                return .warning
            default:
                return .analytic
            }
        }
    }
}

#Preview {
    CreateAvatarView()
        .environment(AIManager(imageGenerationService: MockAIService(), textGenerationService: MockAIService()))
        .environment(AuthManager(service: MockAuthService(user: .mock())))
        .environment(AvatarManager(service: MockRemoteAvatarService(), local: MockLocalAvatarPersistence()))
}
