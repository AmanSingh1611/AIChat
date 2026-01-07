//
//  AppState.swift
//  AIChat
//
//  Created by Aman on 07/01/26.
//

import SwiftUI

@Observable
class AppState {
    
    private(set) var showTabBarView: Bool {
        didSet {
            UserDefaults.showTabbarView = showTabBarView
        }
    }
    
    init(showTabBarView: Bool = UserDefaults.showTabbarView) {
        self.showTabBarView = showTabBarView
    }
    
    func updateViewState(showTabBarView: Bool) {
        self.showTabBarView = showTabBarView
    }
}

extension UserDefaults {
    private struct Keys {
        static let showTabbarView = "showTabbarView"
    }
    
    static var showTabbarView: Bool {
        get {
            standard.bool(forKey: Keys.showTabbarView)
        }
        set {
            standard.set(newValue, forKey: Keys.showTabbarView)
        }
    }
}
