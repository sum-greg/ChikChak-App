//
//  NewsCell.swift
//  ChikChak App
//
//  Created by Григорий Сумлинский on 11.02.2023.
//

import UIKit


// MARK: - NewsCell class

class NewsCell: UITableViewCell {
    
    static let reuseId = "NewsCell"
    
    // MARK: IBOutlets
    
    @IBOutlet var mainContentView: UIView!
    @IBOutlet var mainTextLabel: UILabel!
    
    @IBOutlet var firstPlaceView: UIView!
    @IBOutlet var firstPlaceProfileImageView: UIImageView!
    @IBOutlet var firstPlaceUsernameLabel: UILabel!
    @IBOutlet var firstPlaceScoreLabel: UILabel!
    @IBOutlet var firstPlaceUserScore: UILabel!
    @IBOutlet var firstPlacePrizeAmount: UILabel!
    @IBOutlet var firstPlacePrizeLabel: UILabel!
    
    @IBOutlet var secondPlaceView: UIView!
    @IBOutlet var secondPlaceProfileImageView: UIImageView!
    @IBOutlet var secondPlaceUsernameLabel: UILabel!
    @IBOutlet var secondPlaceScoreLabel: UILabel!
    @IBOutlet var secondPlaceUserScore: UILabel!
    @IBOutlet var secondPlacePrizeAmount: UILabel!
    @IBOutlet var secondPlacePrizeLabel: UILabel!
    
    @IBOutlet var thirdPlaceView: UIView!
    @IBOutlet var thirdPlaceProfileImageView: UIImageView!
    @IBOutlet var thirdPlaceUsernameLabel: UILabel!
    @IBOutlet var thirdPlaceScoreLabel: UILabel!
    @IBOutlet var thirdPlaceUserScore: UILabel!
    @IBOutlet var thirdPlacePrizeAmount: UILabel!
    @IBOutlet var thirdPlacePrizeLabel: UILabel!
    
    @IBOutlet var mipPlaceView: UIView!
    @IBOutlet var mipPlaceProfileImageView: UIImageView!
    @IBOutlet var mipPlaceUsernameLabel: UILabel!
    @IBOutlet var mipPlaceScoreLabel: UILabel!
    @IBOutlet var mipPlaceUserScore: UILabel!
    @IBOutlet var mipPlacePrizeAmount: UILabel!
    @IBOutlet var mipPlacePrizeLabel: UILabel!
    
    @IBOutlet var prizeAmountLabel: UILabel!
    
    //    var cell: FeedViewModel.Cell?
    
    // MARK: awakeFromNib()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
    }
    
    // MARK: - set()
    
    func set(contestModel: ContestModel) {
        mainContentView.layer.cornerRadius = 15
        firstPlaceView.layer.cornerRadius = 15
        secondPlaceView.layer.cornerRadius = 15
        thirdPlaceView.layer.cornerRadius = 15
        mipPlaceView.layer.cornerRadius = 15
        
        firstPlaceProfileImageView.layer.cornerRadius = firstPlaceProfileImageView.frame.height / 2
        secondPlaceProfileImageView.layer.cornerRadius = secondPlaceProfileImageView.frame.height / 2
        thirdPlaceProfileImageView.layer.cornerRadius = thirdPlaceProfileImageView.frame.height / 2
        mipPlaceProfileImageView.layer.cornerRadius = mipPlaceProfileImageView.frame.height / 2
        
        prizeAmountLabel.text = contestModel.prizeAmount + " $"
    }
}
