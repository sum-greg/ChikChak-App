//
//  SettingsProfileViewController.swift
//  ChikChak App
//
//  Created by Григорий Сумлинский on 11.02.2023.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit
import Firebase


// MARK: - NewsVCDelegate protocol

protocol NewsVCDelegate: AnyObject {
    func setSecondSegmentedControlIndex()
}

// MARK: - SettingsProfileViewController class

class SettingsProfileViewController: UIViewController {
    
    weak var delegate: NewsVCDelegate?
    let networkService = NetworkService()
    
    var ref: DatabaseReference!
    var currentAuthUser: UserProfileModel!
    
    // MARK: IBOutlets
    
    @IBOutlet var mainBackgroundView: UIView!
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet var navigationBackgroundView: UIView!
    
    @IBOutlet var mainInfoBackgroundView: UIView!
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var usernameProfileLabel: UILabel!
    @IBOutlet var emailProfileLabel: UILabel!
    
    @IBOutlet var pushNotificationsBackgroundView: UIView!
    @IBOutlet var allNotificationsSwitch: UISwitch!
    @IBOutlet var announceNewContestNotificationsSwitch: UISwitch!
    @IBOutlet var changeContestStatusNotificationsSwitch: UISwitch!
    @IBOutlet var changeYourPositionOnWinnersNotificationsSwitch: UISwitch!
    
    @IBOutlet var mySubscriptionsBackgroundView: UIView!
    @IBOutlet var currentContestSubscriptionLabel: UILabel!
    @IBOutlet var moveToCurrentContestVCButton: UIButton!
    @IBOutlet var nextContestSubscriptionLabel: UILabel!
    @IBOutlet var moveToNextContestVCButton: UIButton!
    
    @IBOutlet var deleteMyProfileButton: UIButton!
    
    // MARK: viewDidLoad()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
    }
    
    // MARK: viewWillAppear()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mainBackgroundView.isHidden = true
        
        guard let currentUser = Auth.auth().currentUser else { return }
        ref.child("users").child(currentUser.uid).observe(DataEventType.value, with: { [ weak self ] snapshot in
            self?.currentAuthUser = UserProfileModel(snapshot: snapshot)
            
            self?.loadingIndicator.stopAnimating()
            self?.setupIBOutlets()
            
        })
    }
    
    // MARK: - IBActions | editUsernameAction()
    
    @IBAction func editUsernameAction(_ sender: Any) {
        let editUsernameAlert = UIAlertController(title: "ИЗМЕНЕНИЕ", message:  "Введите новое имя пользователя", preferredStyle: UIAlertController.Style.alert)
        
        editUsernameAlert.addTextField { [ weak self ] textField in
            textField.text = self?.usernameProfileLabel.text
            textField.placeholder = "username"
        }
        
        let yesAction = UIAlertAction(title:  "Изменить", style: UIAlertAction.Style.default, handler: { [ weak self ] _ in
            
            self?.currentAuthUser.username = (editUsernameAlert.textFields?.first?.text)!
            self?.networkService.updateUserProfile(userProfileModel: (self?.currentAuthUser)!)
            
            self?.usernameProfileLabel.text = editUsernameAlert.textFields?.first?.text
        })
        let cancelAction = UIAlertAction(title:  "Закрыть", style: UIAlertAction.Style.cancel)
        
        editUsernameAlert.addAction(yesAction)
        editUsernameAlert.addAction(cancelAction)
        
        present(editUsernameAlert, animated: true)
    }
    
    // MARK: allNotifSwitchAction()
    
    @IBAction func allNotifSwitchAction(_ sender: Any) {
        currentAuthUser.allNotif = !currentAuthUser.allNotif
        
        switch allNotificationsSwitch.isOn {
        case true:
            currentAuthUser.announceNewContestNotif = true
            currentAuthUser.startEndContestNotif = true
            currentAuthUser.changeYourPositionNotif = true
            
            networkService.updateUserProfile(userProfileModel: currentAuthUser)
        case false:
            currentAuthUser.announceNewContestNotif = false
            currentAuthUser.startEndContestNotif = false
            currentAuthUser.changeYourPositionNotif = false
            
            networkService.updateUserProfile(userProfileModel: currentAuthUser)
        }
    }
    
    // MARK: announceNewContestNotifSwitchAction()
    
    @IBAction func announceNewContestNotifSwitchAction(_ sender: Any) {
        currentAuthUser.announceNewContestNotif = !currentAuthUser.announceNewContestNotif
        networkService.updateUserProfile(userProfileModel: currentAuthUser)
    }
    
    // MARK: changeContestStatusNotifSwitchAction()
    
    @IBAction func changeContestStatusNotifSwitchAction(_ sender: Any) {
        currentAuthUser.startEndContestNotif = !currentAuthUser.startEndContestNotif
        networkService.updateUserProfile(userProfileModel: currentAuthUser)
    }
    
    // MARK: changeYourPositionOnWinnersNotifSwitchAction()
    
    @IBAction func changeYourPositionOnWinnersNotifSwitchAction(_ sender: Any) {
        currentAuthUser.changeYourPositionNotif = !currentAuthUser.changeYourPositionNotif
        networkService.updateUserProfile(userProfileModel: currentAuthUser)
    }
    
    // MARK: moveToCurrentContestVCAction()
    
    @IBAction func moveToCurrentContestVCAction(_ sender: Any) {
        self.tabBarController?.selectedIndex = 1
    }
    
    // MARK: moveToNextContestVCAction()
    
    @IBAction func moveToNextContestVCAction(_ sender: Any) {
        self.tabBarController?.selectedIndex = 0
        delegate?.setSecondSegmentedControlIndex()
    }
    
    // MARK: deleteMyProfileAction()
    
    @IBAction func deleteMyProfileAction(_ sender: Any) {
        let deleteProfileWarningAlert = UIAlertController(title: "УДАЛЕНИЕ", message:  "Вы уверены, что хотите удалить свой аккаунт? \n\nЭто действие безвозвратное. \n\nДля подтвержедения введите ваш username и нажмите 'Подтвердить'", preferredStyle: UIAlertController.Style.alert)
        deleteProfileWarningAlert.addTextField { textField in
            textField.placeholder = "введите ваш username"
            textField.isSecureTextEntry = true
        }
        let yesAction = UIAlertAction(title:  "Подтвердить", style: UIAlertAction.Style.destructive, handler: { [ weak self ] _ in
            
            if self?.currentAuthUser.username == deleteProfileWarningAlert.textFields?.first?.text {
                let user = Auth.auth().currentUser
                user?.delete { [ weak self ] error in
                    if error != nil {
                        print(error!.localizedDescription)
                    } else {
                        self?.networkService.removeUserProfile(userProfileModel: (self?.currentAuthUser)!)
                        
                        guard self?.parent?.parent?.parent != nil,
                              let myVC = self?.parent?.parent else { return }
                        myVC.willMove(toParent: nil)
                        myVC.view.removeFromSuperview()
                        myVC.removeFromParent()
                    }
                }
            }
        })
        let noAction = UIAlertAction(title:  "Нет", style: UIAlertAction.Style.cancel)
        
        deleteProfileWarningAlert.addAction(yesAction)
        deleteProfileWarningAlert.addAction(noAction)
        
        present(deleteProfileWarningAlert, animated: true)
    }
    
    // MARK: - setupIBOutlets
    
    private func setupIBOutlets() {
        mainBackgroundView.isHidden = false
        
        navigationBackgroundView.layer.cornerRadius = 10
        
        mainInfoBackgroundView.layer.cornerRadius = 15
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        
        pushNotificationsBackgroundView.layer.cornerRadius = 15
        
        mySubscriptionsBackgroundView.layer.cornerRadius = 15
        
        emailProfileLabel.text = currentAuthUser.email
        usernameProfileLabel.text = currentAuthUser.username
        allNotificationsSwitch.isOn = currentAuthUser.allNotif
        announceNewContestNotificationsSwitch.isOn = currentAuthUser.announceNewContestNotif
        changeContestStatusNotificationsSwitch.isOn = currentAuthUser.startEndContestNotif
        changeYourPositionOnWinnersNotificationsSwitch.isOn = currentAuthUser.changeYourPositionNotif
        
        if currentAuthUser.isRoot {
            mySubscriptionsBackgroundView.isHidden = true
            deleteMyProfileButton.isHidden = true
        } else {
            if currentAuthUser.currentContestSubscriptionIsActive {
                currentContestSubscriptionLabel.text = "Участие в текущем конкурсе АКТИВНО"
                moveToCurrentContestVCButton.isHidden = true
            }
            if currentAuthUser.newContestSubscriptionIsActive {
                nextContestSubscriptionLabel.text = "Участие в предстоящем конкурсе АКТИВНО"
                moveToNextContestVCButton.isHidden = true
            }
        }
    }
}
