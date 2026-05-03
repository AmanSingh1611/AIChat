//
//  LogsManager.swift
//  AIChat
//
//  Created by Aman Kumar Singh on 03/05/26.
//
import SwiftUI

@MainActor
@Observable
class LogManager {
    
    private let services: [LogService]
    
    init(services: [LogService] = []) {
        self.services = services
    }
    
    func identifyUser(userId: String, name: String?, email: String?) {
        for service in services {
            service.identifyUser(userId: userId, name: name, email: email)
        }
    }
    
    func addUserProperties(dict: [String: Any], isHighPriority: Bool) {
        for service in services {
            service.addUserProperties(dict: dict, isHighPriority: isHighPriority)
        }
    }
    
    func deleteUserProfile() {
        for service in services {
            service.deleteUserProfile()
        }
    }
    
    func trackEvent(eventName: String, parameters: [String: Any]? = nil, type: LogType = .analytic) {
        let event = AnyLoggableEvent(eventName: eventName, parameters: parameters, type: type)
        for service in services {
            service.trackEvent(event: event)
        }
    }
    
    func trackEvent(event: AnyLoggableEvent) {
        for service in services {
            service.trackEvent(event: event)
        }
    }

    func trackEvent(event: LoggableEvent) {
        for service in services {
            service.trackEvent(event: event)
        }
    }
    
    func trackScreenEvent(event: LoggableEvent) {
        for service in services {
            service.trackScreenEvent(event: event)
        }
    }
}
