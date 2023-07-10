//
//  AlertNotification.swift
//  SelfFileManager
//
//  Created by Руслан Гайфуллин on 09.07.2023.
//

import Foundation
import UIKit

final class AlertNotification {
    static let shared = AlertNotification()
    
    init() {}
    
    func showAlert(_ viewController: UIViewController,_ error: String) {
        let optionMenu = UIAlertController(title: "Ошибка", message: "\(error)", preferredStyle: .alert)
        let optionAction = UIAlertAction(title: "Ok", style: .default)
        optionMenu.addAction(optionAction)
        viewController.present(optionMenu, animated: true)
    }
    
    func showPickerChangePassword(in viewController: UIViewController, withTitle title: String, completion: @escaping (_ pass: String)->Void) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Введите новый пароль"
        }
        let actionOK = UIAlertAction(title: "OK", style: .default) { action in
            if let pass = alert.textFields?[0].text{
                completion(pass)
            }
        }
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(actionOK)
        alert.addAction(actionCancel)
        viewController.present(alert, animated: true)
    }
    
    func showPickerAddFolder(in viewController: UIViewController, withTitle title: String, completion: @escaping (_ text: String)->Void) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Введите название папки"
        }
        let actionOK = UIAlertAction(title: "OK", style: .default) { action in
            if let text = alert.textFields?[0].text {
                completion(text)
            }
        }
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(actionOK)
        alert.addAction(actionCancel)
        viewController.present(alert, animated: true)
    }
}
