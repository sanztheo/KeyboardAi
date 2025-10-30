//
//  KeyboardSettings.swift
//  KeyboardAi
//
//  Created by Sanz on 30/10/2025.
//

import Foundation

class KeyboardSettings {
    static let shared = KeyboardSettings()

    
    // App Group identifier - IMPORTANT: You need to configure this in Xcode
    // Go to Target -> Signing & Capabilities -> Add App Groups
    // Use the same identifier for both the app and keyboard extension
    private let appGroupIdentifier = "group.tye.KeyboardAi"

    private var userDefaults: UserDefaults? {
        return UserDefaults(suiteName: appGroupIdentifier)
    }

    private let buttonTextKey = "customButtonText"

    var customButtonText: String {
        get {
            return userDefaults?.string(forKey: buttonTextKey) ?? "Bonjour"
        }
        set {
            userDefaults?.set(newValue, forKey: buttonTextKey)
            userDefaults?.synchronize()
        }
    }
}
