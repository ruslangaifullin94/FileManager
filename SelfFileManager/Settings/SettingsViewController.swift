//
//  SettingsViewController.swift
//  SelfFileManager
//
//  Created by Руслан Гайфуллин on 08.07.2023.
//

import UIKit
import KeychainSwift

class SettingsViewController: UIViewController {

    let keychain = KeychainSwift()
    private var model: Model
    weak var delegate: ViewControllerDelegate?
    
    private lazy var sortLabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Sorted"
        label.tintColor = .systemGray3
        return label
    }()
    
    private lazy var switchSort: UISegmentedControl = {
       let sortSwitch = UISegmentedControl(items: ["A-Z","Z-A"])
        sortSwitch.translatesAutoresizingMaskIntoConstraints = false
        sortSwitch.selectedSegmentIndex = 0
        sortSwitch.tintColor = .black
        sortSwitch.backgroundColor = .systemGray3
        sortSwitch.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
        
        return sortSwitch
    }()
    
    private lazy var changePasswordButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Change Password", for: .normal)
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        button.setTitleColor(.black, for: .normal)
        button.tintColor = .black
        button.backgroundColor = .systemGray3
        return button
    }()
    
    init(model: Model) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        view.backgroundColor = .systemBackground
        setupConstraits()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let sortValue = UserDefaults.standard.bool(forKey: "sort")
        if sortValue {
            switchSort.selectedSegmentIndex = 0
        } else {
            switchSort.selectedSegmentIndex = 1
        }
        
    }
    
    private func setupConstraits() {
        view.addSubview(sortLabel)
        view.addSubview(switchSort)
        view.addSubview(changePasswordButton)
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            sortLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 50),
            sortLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            sortLabel.heightAnchor.constraint(equalToConstant: 40),
            sortLabel.widthAnchor.constraint(equalToConstant: 100),
            
            switchSort.centerYAnchor.constraint(equalTo: sortLabel.centerYAnchor),
            switchSort.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            
            changePasswordButton.topAnchor.constraint(equalTo: sortLabel.bottomAnchor, constant: 40),
            changePasswordButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            changePasswordButton.heightAnchor.constraint(equalToConstant: 40),
            changePasswordButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20)
        ])
    }
    
    @objc private func switchValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            UserDefaults.standard.set(true, forKey: "sort")
            let sortValue = UserDefaults.standard.bool(forKey: "sort")
            print(sortValue)
            let sort = model.items.sorted(by: <)
            model.items = sort
            delegate?.reload()

        case 1:
            UserDefaults.standard.set(false, forKey: "sort")
//            let sortValue = UserDefaults.standard.bool(forKey: "sort")
            let sort = model.items.sorted(by: >)
            model.items = sort
            delegate?.reload()
        default:
            break
        }
    }

    @objc private func didTapButton() {
        AlertNotification.shared.showPickerChangePassword(in: self, withTitle: "Сменить пароль?") { pass in
            self.keychain.set(pass, forKey: "myPass")
        }
    }
}
