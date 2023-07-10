//
//  LoginViewModel.swift
//  SelfFileManager
//
//  Created by Руслан Гайфуллин on 09.07.2023.
//

import Foundation

protocol LoginViewModelProtocol {
    var stateChanger: ((LoginViewModel.State) -> Void)? {get set}
    func didTapDeleteKey()
    func checkAuth()
    func didTapCreatePassButton(_ pass: String)
    func checkPassword(_ pass: String)
    func secondCheckPassword(_ pass: String)
}


final class LoginViewModel {
    var loginCheck: LoginCheckProtocol

    var password: String = ""
    
    enum State {
        case auth
        case notAuth
        case secondCheck
        case login
        case error(error: String)
        case noPasswordInBase(error: String)
    }
        
    var stateChanger: ((State) -> Void)?
    
    private var state: State = .notAuth {
        didSet {
            self.stateChanger?(state)
        }
    }
    
    init(loginCheck: LoginCheckProtocol) {
        self.loginCheck = loginCheck
    }
    
    
}

extension LoginViewModel: LoginViewModelProtocol {
    
    func didTapDeleteKey() {
        loginCheck.deleteKey()
        checkAuth()
    }
    
    func checkAuth() {
       loginCheck.checkAuth { [weak self] userAuth in
           guard let self else {return}
           switch userAuth {
           case true:
               self.state = .auth
           case false:
               self.state = .notAuth
           }
       }
   }
    
    func didTapCreatePassButton(_ pass: String) {
        if pass.count < 4 {
            state = .error(error: "Пароль должен быть не менее 4х символов")
        } else {
            loginCheck.registerAccount(pass: pass)
            state = .secondCheck
        }
    }
    
    func checkPassword(_ pass: String) {
        if pass.count < 4 {
            state = .error(error: "Пароль должен быть не менее 4х символов")
        } else {
            loginCheck.checkPassword(pass) { [weak self] passCheckResult in
                guard let self else { return }
                switch passCheckResult {
                case true:
                    self.state = .login
                case false:
                    self.state = .noPasswordInBase(error: "Неправильный пароль. Повторите ввод")
                }
            }
        }
    }
    
    func secondCheckPassword(_ pass: String) {
        loginCheck.checkPassword(pass) { [weak self] passCheckResult in
            guard let self else { return }
            switch passCheckResult {
            case true:
                self.state = .login
            case false:
                self.state = .noPasswordInBase(error: "Неправильный пароль. Повторите ввод")
            }
        }
    }
    
}
