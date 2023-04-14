//
//  CurrentContestViewController.swift
//  ChikChak App
//
//  Created by Григорий Сумлинский on 11.02.2023.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit
import Firebase


// MARK: - CurrentContestViewController class

class CurrentContestViewController: UIViewController {
    
    let networkService = NetworkService()
    
    var ref: DatabaseReference!
    var currentAuthUser: UserProfileModel!
    var currentContest: ContestModel!
    
    // MARK: IBOutlets
    
    @IBOutlet var mainBackgroundView: UIView!
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet var navigationBackgroundView: UIView!
    @IBOutlet var timerBackgroundView: UIView!
    @IBOutlet var daysTimerLabel: UILabel!
    @IBOutlet var hoursTimerLabel: UILabel!
    @IBOutlet var minutesTimerLabel: UILabel!
    @IBOutlet var secondsTimerLabel: UILabel!
    @IBOutlet var joinToContestButton: UIButton!
    @IBOutlet var playGameButton: UIButton!
    
    @IBOutlet var myScoresBackgroundView: UIView!
    @IBOutlet var myScoresLabel: UILabel!
    @IBOutlet var myBestScoreView: UIView!
    @IBOutlet var myBestScoreLabel: UILabel!
    @IBOutlet var myAttemptsAmountView: UIView!
    @IBOutlet var myAttemptsAmountLabel: UILabel!
    
    @IBOutlet var prizeBackgroundView: UIView!
    @IBOutlet var prizeAmountLabel: UILabel!
    @IBOutlet var prizeAmountNumber: UILabel!
    @IBOutlet var firstPlaceBackgroundView: UIView!
    @IBOutlet var secondPlaceBackgroundView: UIView!
    @IBOutlet var thirdPlaceBackgroundView: UIView!
    @IBOutlet var mipBackgroundView: UIView!
    
    @IBOutlet var winnersBackgroundView: UIView!
    @IBOutlet var winnersLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var mipWinnerView: UIView!
    @IBOutlet var mipWinnerImage: UIImageView!
    
    // MARK: viewDidLoad()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        playGameButton.isHidden = true
        
        ref = Database.database().reference()
    }
    
    // MARK: viewWillAppear()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mainBackgroundView.isHidden = true
        loadingIndicator.startAnimating()
        
        startTimer()
        
        guard let currentUser = Auth.auth().currentUser else { return }
        ref.child("users").child(currentUser.uid).observe(DataEventType.value, with: { [ weak self ] snapshot in
            self?.currentAuthUser = UserProfileModel(snapshot: snapshot)
            
            self?.loadingIndicator.stopAnimating()
            self?.setupIBOutlets()
            self?.updatePrizeAndWinners()
            
        })
        
        ref.child("contests").observe(.value) { [ weak self ] snapshot  in
            for childSnapshot in snapshot.children {
                let thisContest = ContestModel(snapshot: childSnapshot as! DataSnapshot)
                
                if thisContest.status == .current {
                    self?.currentContest = thisContest
                }
            }
            
//            self?.setupTableView()
//            self?.tableView.reloadData()
            self?.setupInfoForCurrentContest()
        }
    }
    
    // MARK: - IBActions | joinToContestAction()
    
    @IBAction func joinToContestAction(_ sender: Any) {
        currentAuthUser.currentContestSubscriptionIsActive = true
        networkService.updateUserProfile(userProfileModel: currentAuthUser)
        
        joinToContestButton.isHidden = true
        playGameButton.isHidden = false
    }
    
    // MARK: openGameAction()
    
    @IBAction func openGameAction(_ sender: Any) {
    }
    
    // MARK: infoAboutMIPShowAction()
    
    @IBAction func infoAboutMIPShowAction(_ sender: Any) {
        self.showToast(message: "MIP - игрок с наибольшим количеством попыток", font: .systemFont(ofSize: 12.0))
    }
    
    // MARK: - setupTableView()
    
    private func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
        
        let nib = UINib(nibName: "BestPlayerCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: BestPlayerCell.reuseId)
        
        tableView.backgroundColor = .clear
        tableView.contentInset = UIEdgeInsets(top: -5, left: 0, bottom: -5, right: 0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: -5, left: 0, bottom: -5, right: 0)
    }
    
    // MARK: setupIBOutlets()
    
    private func setupIBOutlets() {
        mainBackgroundView.isHidden = false
        
        navigationBackgroundView.layer.cornerRadius = 10
        timerBackgroundView.layer.cornerRadius = 15
        
        myScoresBackgroundView.layer.cornerRadius = 15
        myBestScoreView.layer.cornerRadius = 15
        myAttemptsAmountView.layer.cornerRadius = 15
        
        prizeBackgroundView.layer.cornerRadius = 15
        firstPlaceBackgroundView.layer.cornerRadius = 15
        secondPlaceBackgroundView.layer.cornerRadius = 15
        thirdPlaceBackgroundView.layer.cornerRadius = 15
        mipBackgroundView.layer.cornerRadius = 15
        
        winnersBackgroundView.layer.cornerRadius = 15
        mipWinnerView.layer.cornerRadius = 15
        mipWinnerImage.layer.cornerRadius = mipWinnerImage.frame.height / 2
        
        if currentAuthUser.isRoot {
            joinToContestButton.isEnabled = false
            playGameButton.isEnabled = false
            myScoresBackgroundView.isHidden = true
        } else {
            myBestScoreLabel.text = String(currentAuthUser.bestScore)
            myAttemptsAmountLabel.text = String(currentAuthUser.attemptsCount)
        }
    }
    
    // MARK: setupInfoForCurrentContest()
    
    private func setupInfoForCurrentContest() {
        if currentContest != nil {
            prizeAmountNumber.text = currentContest.prizeAmount + " $"
        } else {
            mainBackgroundView.isHidden = true
        }
    }
    
    // MARK: startTimer()
    
    private func startTimer() {
        let timeDateEnd = Date(timeIntervalSinceNow: 6)
        
        _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [ weak self ] timer in
            DispatchQueue.main.async {
                let timeDateNow = Date()
                let interval = timeDateEnd.timeIntervalSince(timeDateNow)
                
//                if timeDateNow.compare(timeDateEnd) != ComparisonResult.orderedAscending {
                if interval < 1 {
                    timer.invalidate()
                }
                
                let days =  (interval / (60*60*24)).rounded(.down)
                let daysRemainder = interval.truncatingRemainder(dividingBy: 60*60*24)
                let hours = (daysRemainder / (60 * 60)).rounded(.down)
                let hoursRemainder = daysRemainder.truncatingRemainder(dividingBy: 60 * 60).rounded(.down)
                let minutes  = (hoursRemainder / 60).rounded(.down)
                let minutesRemainder = hoursRemainder.truncatingRemainder(dividingBy: 60).rounded(.down)
                let seconds = minutesRemainder.truncatingRemainder(dividingBy: 60).rounded(.down)
                
                self?.daysTimerLabel.text = String(format: "%.0f", days)
                self?.hoursTimerLabel.text = String(format: "%.0f", hours)
                self?.minutesTimerLabel.text = String(format: "%.0f", minutes)
                self?.secondsTimerLabel.text = String(format: "%.0f", seconds)
            }
        })
    }
    
    // MARK: updatePrizeAndWinners()
    
    private func updatePrizeAndWinners() {
        let timeDateNow = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM, hh:mm"
        dateFormatter.locale = Locale(identifier: "ru_RU")
        myScoresLabel.text = "Мои результаты на " + dateFormatter.string(from: timeDateNow)
        prizeAmountLabel.text = "Сумма призовых на " + dateFormatter.string(from: timeDateNow)
        winnersLabel.text = "Победители на " + dateFormatter.string(from: timeDateNow)
        
        _ = Timer.scheduledTimer(withTimeInterval: 60, repeats: true, block: { [ weak self ] timer in
            DispatchQueue.main.async {
                let timeDateNow = Date()
                self?.prizeAmountLabel.text = "Сумма призовых на " + dateFormatter.string(from: timeDateNow)
                self?.winnersLabel.text = "Победители на " + dateFormatter.string(from: timeDateNow)
            }
        })
    }
    
    // MARK: showToast()
    
    private func showToast(message : String, font: UIFont) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 175, y: self.view.frame.size.height - 130, width: 350, height: 35))
        toastLabel.backgroundColor = UIColor.darkGray.withAlphaComponent(0.8)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 15
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 0.5, delay: 5, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}


// MARK: - UITableViewDelegate, UITableViewDataSource

extension CurrentContestViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BestPlayerCell.reuseId, for: indexPath) as! BestPlayerCell
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
}
