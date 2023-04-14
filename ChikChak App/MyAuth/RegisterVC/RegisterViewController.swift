//
//  RegisterViewController.swift
//  ChikChak App
//
//  Created by Григорий Сумлинский on 11.02.2023.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit
import Firebase


// MARK: - RegisterViewController class

class RegisterViewController: UIViewController {
    
    let networkService = NetworkService()
    
    var ref: DatabaseReference!
    
    // MARK: IBOutlets
    
    @IBOutlet var registerBackgroundView: UIView!
    @IBOutlet var errorLabel: UILabel!
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var passwordAgainTextField: UITextField!
    
    // MARK: viewDidLoad()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUIOutlets()
        
        ref = Database.database().reference().child("users")
    }
    
    // MARK: - IBActions | registerAction()
    
    @IBAction func registerAction(_ sender: Any) {
        guard let username = usernameTextField.text,
              let email = emailTextField.text,
              let password = passwordTextField.text,
              let password2 = passwordAgainTextField.text,
              username != "",
              email != "",
              password != "",
              password2 != "" else {
            showWarningLabel(withText: "Пожалуйста, заполните все поля")
            return
        }
        
        if password != password2 {
            showWarningLabel(withText: "Пароли не совпадают! Пожалуйста, попробуйте еще раз")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { [ weak self ] user, error in
            if error != nil {
                self?.showWarningLabel(withText: error!.localizedDescription)
            }
            
            let window = UIApplication.shared.connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .first(where: { $0 is UIWindowScene })
                .flatMap({ $0 as? UIWindowScene })?.windows
                .first(where: \.isKeyWindow)
            guard let rootVC = window?.rootViewController as? LoginViewController else { return }
            
            if user != nil {
                Auth.auth().currentUser?.sendEmailVerification { [ weak self ] currentError in
                    if currentError != nil {
                        self?.showWarningLabel(withText: currentError!.localizedDescription)
                    }
                    return
                }
                
//                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
//                changeRequest?.displayName = username
//                changeRequest?.commitChanges { currentError in
//                    if currentError != nil {
//                        self?.showWarningLabel(withText: currentError!.localizedDescription)
//                    }
//                    return
//                }
                
                let newUserProfile = UserProfileModel(uid: (user?.user.uid)!, username: username, email: email)
                self?.networkService.updateUserProfile(userProfileModel: newUserProfile)
                
                rootVC.emailTextField.text = email
                rootVC.passwordTextField.text = password
                self?.closeChildView()
                
                return
            } else {
                self?.showWarningLabel(withText: error!.localizedDescription)
            }
        }
    }
    
    // MARK: moveToLoginVCAction()
    
    @IBAction func moveToLoginVCAction(_ sender: Any) {
        self.closeChildView()
    }
    
    // MARK: - setupUIOutlets()
    
    private func setupUIOutlets() {
        registerBackgroundView.layer.cornerRadius = 15
        
        errorLabel.isHidden = true
    }
    
    // MARK: closeChildView()
    
    private func closeChildView() {
        guard parent != nil else { return }
        parent!.viewDidLoad()
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
    
    // MARK: showWarningLabel()
    
    private func showWarningLabel(withText text: String) {
        errorLabel.text = text
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: { [ weak self ] in
            self?.errorLabel.isHidden = false
        })
    }
}
