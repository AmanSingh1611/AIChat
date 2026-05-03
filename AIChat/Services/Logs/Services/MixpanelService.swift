//
//  MixpanelService.swift
//  AIChat
//
//  Created by Aman Kumar Singh on 03/05/26.
//

import Mixpanel

struct MixpanelService: LogService {
    
    private var instance: MixpanelInstance {
        Mixpanel.mainInstance()
    }
    
    init(token: String, loggingEnabled: Bool = false) {
        Mixpanel.initialize(token: token, trackAutomaticEvents: true)
        instance.loggingEnabled = loggingEnabled
    }
    
    func identifyUser(userId: String, name: String?, email: String?) {
        instance.identify(distinctId: userId)
        
        if let name {
            instance.people.set(property: "$name", to: name)
        }
        if let email {
            instance.people.set(property: "$email", to: email)
        }
    }
    
    func addUserProperties(dict: [String: Any], isHighPriority: Bool) {
        var userProperties: [String: MixpanelType] = [:]
        
        for (key, value) in dict {
            let key = key.clipped(maxCharacters: 255)
            if let value = value as? MixpanelType {
                userProperties[key] = value
            }
        }
        
        instance.people.set(properties: userProperties)
    }
    
    func deleteUserProfile() {
        instance.people.deleteUser()
    }
    
    func trackEvent(event: any LoggableEvent) {
        guard event.type != .info else { return }
        
        var eventProperties: [String: MixpanelType] = [:]
        
        if let parameters = event.parameters {
            for (key, value) in parameters {
                let key = key.clipped(maxCharacters: 255)
                if let value = value as? MixpanelType {
                    eventProperties[key] = value
                }
            }
        }
        
        instance.track(event: event.eventName, properties: eventProperties.isEmpty ? nil : eventProperties)
    }
    
    func trackScreenEvent(event: any LoggableEvent) {
        trackEvent(event: event)
    }
}
