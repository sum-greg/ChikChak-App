//
//  UIViewController + Storyboard.swift
//  ChikChak App
//
//  Created by Григорий Сумлинский on 11.02.2023.
//

import Foundation
import UIKit


// MARK: - UIViewController extension

extension UIViewController {
    
    // MARK: loadFromStoryboard()
    
    class func loadFromStoryboard<T: UIViewController>() -> T {
        
        let name = String(describing: T.self)
        let storyboard = UIStoryboard(name: name, bundle: nil)
        
        if let viewController = storyboard.instantiateInitialViewController() as? T {
            return viewController
        } else {
            fatalError("Error: No initial view controller in \(name) storyboard!")
        }
    }
}
