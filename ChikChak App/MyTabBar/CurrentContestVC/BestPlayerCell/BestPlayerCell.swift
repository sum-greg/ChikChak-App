//
//  BestPlayerCell.swift
//  ChikChak App
//
//  Created by Григорий Сумлинский on 20.02.2023.
//

import UIKit


// MARK: - BestPlayerCell class

class BestPlayerCell: UITableViewCell {
    
    static let reuseId = "BestPlayerCell"
    
    // MARK: IBOutlets
    
    @IBOutlet var cellBackgroundView: UIView!
    @IBOutlet var placeOnTopLabel: UILabel!
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var prizeAmountLabel: UILabel!
    @IBOutlet var scoreLabel: UILabel!
    @IBOutlet var dateTimeScoreLabel: UILabel!
    
    // MARK: awakeFromNib()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        set()
        
        selectionStyle = .none
    }
    
    // MARK: - set()
    
    func set() {
        cellBackgroundView.layer.cornerRadius = 15
        userImageView.layer.cornerRadius = userImageView.frame.height / 2
    }
}
