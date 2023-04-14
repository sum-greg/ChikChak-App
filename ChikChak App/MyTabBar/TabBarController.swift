//
//  TabBarController.swift
//  ChikChak App
//
//  Created by Григорий Сумлинский on 11.02.2023.
//

import UIKit
import Firebase


// MARK: - TabBarController class

class TabBarController: UITabBarController {
    
    // MARK: viewDidLoad()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        
        tabBar.tintColor = .systemRed
        tabBar.unselectedItemTintColor = .label
        tabBar.backgroundColor = #colorLiteral(red: 0.6542707086, green: 0.7963560224, blue: 0.9641669393, alpha: 1)
        tabBar.layer.cornerRadius = 10
        
//        UIView.animate(withDuration: 1,
//                       delay: 0,
//                       usingSpringWithDamping: 0.5,
//                       initialSpringVelocity: 1,
//                       options: .curveEaseInOut,
//                       animations: {
//            self.view.transform = CGAffineTransform(scaleX: -1, y: 1)
//        }, completion: nil)
        
        let newsVC: NewsViewController = NewsViewController.loadFromStoryboard()
        let currentContestVC: CurrentContestViewController = CurrentContestViewController.loadFromStoryboard()
        let settingsProfileVC: SettingsProfileViewController = SettingsProfileViewController.loadFromStoryboard()
        
        settingsProfileVC.delegate = newsVC
        
        viewControllers = [
            generateViewController(rootViewController: newsVC, image: UIImage(systemName: "newspaper") ?? #imageLiteral(resourceName: "questionmark.app"), title: "Новости"),
            generateViewController(rootViewController: currentContestVC, image: UIImage(systemName: "gamecontroller") ?? #imageLiteral(resourceName: "questionmark.app"), title: "Конкурс"),
            generateViewController(rootViewController: settingsProfileVC, image: UIImage(systemName: "person") ?? #imageLiteral(resourceName: "questionmark.app"), title: "Мой Профиль")
        ]
    }
    
    // MARK: viewDidAppear()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        UIView.animate(withDuration: 1,
//                       delay: 0,
//                       usingSpringWithDamping: 0.5,
//                       initialSpringVelocity: 1,
//                       options: .curveEaseInOut,
//                       animations: {
//            self.view.transform = CGAffineTransform(scaleX: 1, y: 1)
//        }, completion: nil)
    }
    
    // MARK: - generateViewController()
    
    private func generateViewController(rootViewController: UIViewController, image: UIImage, title: String) -> UIViewController {
        let navigationVC = UINavigationController(rootViewController: rootViewController)
        navigationVC.tabBarItem.image = image
        navigationVC.tabBarItem.title = title
        rootViewController.navigationItem.title = title
        
        let moveToLoginVCButton = UIBarButtonItem(image: UIImage(systemName: "door.left.hand.open"), style: .done, target: self, action: #selector(self.signOutButtonClicked))
        rootViewController.navigationItem.leftBarButtonItem = moveToLoginVCButton
        rootViewController.navigationItem.leftBarButtonItem?.tintColor = .red
        
        return navigationVC
    }
    
    // MARK: signOutButtonClicked()
    
    @objc private func signOutButtonClicked() {
        let logoutWarningAlert = UIAlertController(title: "ВЫХОД", message:  "Вы уверены, что хотите выйти из аккаунта?", preferredStyle: UIAlertController.Style.alert)
        
        let yesAction = UIAlertAction(title:  "Да", style: UIAlertAction.Style.destructive, handler: { [ weak self ] _ in
            guard let strongSelf = self else { return }
            
            do {
                try Auth.auth().signOut()
                
                guard strongSelf.parent != nil else { return }
                strongSelf.parent!.viewDidLoad()
                strongSelf.willMove(toParent: nil)
                strongSelf.view.removeFromSuperview()
                strongSelf.removeFromParent()
            } catch {
                print(error.localizedDescription)
            }
        })
        
        let noAction = UIAlertAction(title:  "Нет", style: UIAlertAction.Style.cancel)
        
        logoutWarningAlert.addAction(yesAction)
        logoutWarningAlert.addAction(noAction)
        
        present(logoutWarningAlert, animated: true)
    }
}
