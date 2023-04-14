//
//  LoginViewController.swift
//  ChikChak App
//
//  Created by Григорий Сумлинский on 11.02.2023.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit
import Firebase


// MARK: - LoginViewController class

class LoginViewController: UIViewController {
    
    // MARK: IBOutlets
    
    @IBOutlet var loginBackgroundView: UIView!
    @IBOutlet var errorLabel: UILabel!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    // MARK: viewDidLoad()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUIOutlets()
    }
    
    // MARK: viewWillAppear()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard Auth.auth().currentUser != nil else { return }
        
        let tabBarVC = TabBarController()
        self.addChild(tabBarVC)
        tabBarVC.didMove(toParent: self)
        self.view.addSubview(tabBarVC.view)
    }
    
    // MARK: - IBActions | loginAction()
    // MARK: loginAction()
    
    @IBAction func loginAction(_ sender: Any) {
        guard let email = emailTextField.text,
              let password = passwordTextField.text,
              email != "",
              password != "" else {
            showWarningLabel(withText: "Пожалуйста, введите email и пароль")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { [ weak self ] user, error in
            guard let strongSelf = self else { return }
            
            if error != nil {
                strongSelf.showWarningLabel(withText: error!.localizedDescription)
                return
            }
            
            if user != nil {
                guard let user = Auth.auth().currentUser else { return }
                
                if !(user.isEmailVerified) {
                    strongSelf.showWarningLabel(withText: "Пожалуйста, подтвердите свой email")
                    return
                }
                
                let tabBarVC = TabBarController()
                strongSelf.addChild(tabBarVC)
                tabBarVC.didMove(toParent: strongSelf)
                strongSelf.view.addSubview(tabBarVC.view)
                
                strongSelf.passwordTextField.text = ""
                strongSelf.emailTextField.text = ""
                
                return
            }
            
            strongSelf.showWarningLabel(withText: "Непредвиденная ошибка! Пожалуйста, попробуйте еще раз")
        }
    }
    
    // MARK: forgotPasswordAction()
    
    @IBAction func forgotPasswordAction(_ sender: Any) {
        let forgotPasswordAlert = UIAlertController(title: "СБРОС ПАРОЛЯ", message:  "Пожалуйста, введите свой email.\n\nНа него придет письмо, где будет ссылка для восстановления пароля", preferredStyle: UIAlertController.Style.alert)
        
        forgotPasswordAlert.addTextField { textField in
            textField.placeholder = "email"
        }
        
        let sendAction = UIAlertAction(title:  "Подтвердить", style: UIAlertAction.Style.destructive, handler: { [ weak self ] _ in
            guard let email = self?.emailTextField.text else { return }
            Auth.auth().sendPasswordReset(withEmail: email) { [ weak self ] error in
                if error != nil {
                    self?.showWarningLabel(withText: error!.localizedDescription)
                } else {
                    self?.errorLabel.isHidden = true
                }
            }
        })
        let cancelAction = UIAlertAction(title:  "Закрыть", style: UIAlertAction.Style.cancel)
        
        forgotPasswordAlert.addAction(sendAction)
        forgotPasswordAlert.addAction(cancelAction)
        
        present(forgotPasswordAlert, animated: true)
    }
    
    // MARK: moveToRegisterVCAction()
    
    @IBAction func moveToRegisterVCAction(_ sender: Any) {
        let registerVC: RegisterViewController = RegisterViewController.loadFromStoryboard()
        
        self.addChild(registerVC)
        registerVC.didMove(toParent: self)
        self.view.addSubview(registerVC.view)
    }
    
    // MARK: - setupUIOutlets()
    
    private func setupUIOutlets() {
        loginBackgroundView.layer.cornerRadius = 15
        
        passwordTextField.text = ""
        emailTextField.text = ""
        
        errorLabel.isHidden = true
    }
    
    // MARK: showWarningLabel()
    
    private func showWarningLabel(withText text: String) {
        errorLabel.text = text
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: { [ weak self ] in
            self?.errorLabel.isHidden = false
        })
    }
}
