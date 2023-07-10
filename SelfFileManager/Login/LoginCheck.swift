//
//  LoginCheck.swift
//  SelfFileManager
//
//  Created by Руслан Гайфуллин on 09.07.2023.
//

import Foundation
import KeychainSwift

protocol LoginCheckProtocol {
    func registerAccount(pass: String)
    func checkAuth(completion: @escaping (_ userAuth: Bool) -> Void)
    func checkPassword(_ pass: String, completion: @escaping (_ passCheckResult: Bool)->Void)
    func deleteKey()
}

final class LoginCheck {
    let keychain = KeychainSwift()
    
}

extension LoginCheck: LoginCheckProtocol {
    
    func deleteKey() {
        keychain.delete("myPass")
        keychain.set(false, forKey: "auth")
    }
    
    func registerAccount(pass: String) {
        keychain.set(pass, forKey: "myPass")
        keychain.set(true, forKey: "auth")
    }
    
    
    func checkAuth(completion: @escaping (_ userAuth: Bool) -> Void ) {
        guard let auth = keychain.getBool("auth") else {
            completion(false)
            return
        }
        if auth {
            completion(true)
        } else {
            completion(false)
        }
    }
    
    func checkPassword(_ pass: String, completion: @escaping (_ passCheckResult: Bool)->Void) {
        guard let savingPass = keychain.get("myPass") else { return }
        if savingPass == pass {
            completion(true)
        } else {
            completion(false)
        }
    }
}
