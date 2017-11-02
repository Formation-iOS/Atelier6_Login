//
//  UserAccount.swift
//  KeyboardExample
//
//  Created by Claire Reynaud on 01/11/2017.
//  Copyright © 2017 Claire Reynaud EIRL. All rights reserved.
//

import Foundation
import KeychainSwift

class UserAccount {
    
    private enum UserAccountKey : String {
        case username = "username"
        case password = "password"
        case sessionId = "sessionId"
    }
    
    static func save(username: String, password: String, sessionId: String) {
        let keychain = KeychainSwift()
        keychain.set(username, forKey: UserAccountKey.username.rawValue)
        keychain.set(password, forKey: UserAccountKey.password.rawValue)
        keychain.set(sessionId, forKey: UserAccountKey.sessionId.rawValue)
    }
    
    static func clear() {
        let keychain = KeychainSwift()
        keychain.delete(UserAccountKey.username.rawValue)
        keychain.delete(UserAccountKey.password.rawValue)
        keychain.delete(UserAccountKey.sessionId.rawValue)
    }
    
    static func getUsername() -> String? {
        let keychain = KeychainSwift()
        return keychain.get(UserAccountKey.username.rawValue)
    }
    
    static func getPassword() -> String? {
        let keychain = KeychainSwift()
        return keychain.get(UserAccountKey.password.rawValue)
    }
    
    static func getSessionId() -> String? {
        let keychain = KeychainSwift()
        return keychain.get(UserAccountKey.sessionId.rawValue)
    }
    
    static func hasSessionId() -> Bool {
        return getSessionId() != nil
    }
}
