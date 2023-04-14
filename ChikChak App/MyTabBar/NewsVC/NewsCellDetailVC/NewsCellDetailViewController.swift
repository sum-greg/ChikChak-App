//
//  NewsCellDetailViewController.swift
//  ChikChak App
//
//  Created by Григорий Сумлинский on 15.02.2023.
//

import UIKit


// MARK: - NewsCellDetailViewController class

class NewsCellDetailViewController: UIViewController {
    
    // MARK: IBOutlets
    
    @IBOutlet var firstPlaceBackgroundView: UIView!
    @IBOutlet var firstPlaceProfileImageView: UIImageView!
    
    @IBOutlet var secondPlaceBackgroundView: UIView!
    @IBOutlet var secondPlaceProfileImageView: UIImageView!
    
    @IBOutlet var thirdPlaceBackgroundView: UIView!
    @IBOutlet var thirdPlaceProfileImageView: UIImageView!
    
    @IBOutlet var mipBackgroundView: UIView!
    @IBOutlet var mipProfileImageView: UIImageView!
    
    // MARK: viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUIOutlets()
    }
    
    // MARK: - setupUIOutlets()
    
    private func setupUIOutlets() {
        firstPlaceBackgroundView.layer.cornerRadius = 15
        secondPlaceBackgroundView.layer.cornerRadius = 15
        thirdPlaceBackgroundView.layer.cornerRadius = 15
        mipBackgroundView.layer.cornerRadius = 15
        
        firstPlaceProfileImageView.layer.cornerRadius = firstPlaceProfileImageView.frame.height / 2
        secondPlaceProfileImageView.layer.cornerRadius = secondPlaceProfileImageView.frame.height / 2
        thirdPlaceProfileImageView.layer.cornerRadius = thirdPlaceProfileImageView.frame.height / 2
        mipProfileImageView.layer.cornerRadius = mipProfileImageView.frame.height / 2
    }
    
}
