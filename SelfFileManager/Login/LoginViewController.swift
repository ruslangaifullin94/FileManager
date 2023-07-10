//
//  LoginViewController.swift
//  SelfFileManager
//
//  Created by Руслан Гайфуллин on 07.07.2023.
//

import UIKit

class LoginViewController: UIViewController {
    var viewModel: LoginViewModelProtocol
    
    private lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.layer.borderColor = UIColor.black.cgColor
        textField.layer.borderWidth = 0.5
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
        textField.leftViewMode = .always
        textField.placeholder = "enter pass"
        return textField
    }()
    
    private lazy var passButton: UIButton = {
        let button = UIButton()
        button.tintColor = .black
        button.backgroundColor = .systemGray3
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 0.5
        return button
    }()
    
    private lazy var loginStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.addArrangedSubview(passwordTextField)
        stackView.addArrangedSubview(passButton)
        return stackView
    }()
    
    init(viewModel: LoginViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Login"
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark.circle.fill"), style: .done, target: self, action: #selector(deleteKey))
        bindingModel()
        setupSubview()
        viewModel.checkAuth()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = true

    }
    
    private func bindingModel() {
        viewModel.stateChanger = { [weak self] state in
            guard let self else { return }
            switch state {
            case .auth:
                self.passButton.setTitle("Введите пароль", for: .normal)
                self.passButton.addTarget(self, action: #selector(self.loginChecking), for: .touchUpInside)
                
            case .notAuth:
                self.passButton.setTitle("Cоздать пароль", for: .normal)
                self.passButton.addTarget(self, action: #selector(self.createPass), for: .touchUpInside)

            case .secondCheck:
                self.passwordTextField.text = ""
                self.passButton.setTitle("Повторите пароль", for: .normal)
                self.passButton.addTarget(self, action: #selector(self.secondLoginChecking), for: .touchUpInside)
                
            case .error(let error):
                AlertNotification.shared.showAlert(self, error)
                
            case .login:
                self.login()
                
            case .noPasswordInBase(let error):
                AlertNotification.shared.showAlert(self, error)
            }
        }
    }
    
    private func setupSubview() {
        view.addSubview(loginStackView)
        
        NSLayoutConstraint.activate([
            loginStackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            loginStackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            loginStackView.widthAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    @objc private func deleteKey() {
        viewModel.didTapDeleteKey()
    }
    
    @objc private func createPass() {
        guard let pass = passwordTextField.text else { return }
        viewModel.didTapCreatePassButton(pass)
    }
    
    
    @objc private func loginChecking() {
        guard let pass = passwordTextField.text else { return }
        viewModel.checkPassword(pass)
    }
    
    @objc private func secondLoginChecking() {
        guard let pass = passwordTextField.text else { return }
        viewModel.secondCheckPassword(pass)
    }
    
    private func login() {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let model = Model(path: path)
        let viewController = ViewController(model: model)
        let navViewController = UINavigationController(rootViewController: viewController)
        navViewController.tabBarItem = UITabBarItem(title: "File", image: UIImage(systemName: "folder.fill"), tag: 0)
        let settingsViewController = SettingsViewController(model: model)
        settingsViewController.delegate = viewController
        let navSettingsViewController = UINavigationController(rootViewController: settingsViewController)
        navSettingsViewController.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gear"), tag: 1)
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [navViewController,navSettingsViewController]
        navigationController?.pushViewController(tabBarController, animated: true)
    }

}
