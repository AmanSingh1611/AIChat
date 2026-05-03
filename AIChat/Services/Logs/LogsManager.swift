//
//  LogsManager.swift
//  AIChat
//
//  Created by Aman Kumar Singh on 03/05/26.
//

import SwiftUI

protocol LogService {
    func identifyUser(userId: String, name: String?, email: String?)
    func addUserProperties(dict: [String: Any])
    func deleteUserProfile()
    
    func trackEvent(event: LoggableEvent)
    func trackScreenEvent(event: LoggableEvent)
}

protocol LoggableEvent {
    var eventName: String { get }
    var parameters: [String: Any]? { get }
}

struct ConsoleService: LogService {
    
    func identifyUser(userId: String, name: String?, email: String?) {
        let string = """
        Identify User
            userId: \(userId)
            name: \(name ?? "unknown")
            email: \(email ?? "unknown")
        """
        print(string)
    }
    
    func addUserProperties(dict: [String : Any]) {
        var string = """
        Log User Properties
        """
        let sortedKeys = dict.keys.sorted()
        for key in sortedKeys {
            if let value = dict[key] {
                string += "\n (key: \(key), value: \(value))"
            }
        }
        
        print(string)
    }
    
    func deleteUserProfile() {
        var string = """
        Delete User profile
        """
        print(string)
    }
    
    func trackEvent(event: any LoggableEvent) {
        var string = "\(event.eventName)"
        
        if let parameters = event.parameters, !parameters.isEmpty {
            let sortedKeys = parameters.keys.sorted()
            for key in sortedKeys {
                if let value = parameters[key] {
                    string += "\n (key: \(key), value: \(value))"
                }
            }
        }
        
        print(string)
    }
    
    func trackScreenEvent(event: any LoggableEvent) {
        trackEvent(event: event)
    }
}

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
    
    func addUserProperties(dict: [String: Any]) {
        for service in services {
            service.addUserProperties(dict: dict)
        }
    }
    
    func deleteUserProfile() {
        for service in services {
            service.deleteUserProfile()
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
