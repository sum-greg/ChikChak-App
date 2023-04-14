//
//  NewsViewController.swift
//  ChikChak App
//
//  Created by Григорий Сумлинский on 11.02.2023.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit
import Firebase


// MARK: - NewsViewController class

class NewsViewController: UIViewController {
    
    let networkService = NetworkService()
    
    var ref: DatabaseReference!
    var currentAuthUser: UserProfileModel!
    var finishedContests = [ContestModel]()
    var newContest: ContestModel!
    
    // MARK: IBOutlets
    
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet var segmentedControl: UISegmentedControl!
    
    @IBOutlet var freshNewsContentView: UIView!
    @IBOutlet var freshNewsContentSubview: UIView!
    @IBOutlet var timerForCurrentContestView: UIView!
    @IBOutlet var openContestVCButton: UIButton!
    @IBOutlet var daysTimerLabel: UILabel!
    @IBOutlet var hoursTimerLabel: UILabel!
    @IBOutlet var minutesTimerLabel: UILabel!
    @IBOutlet var secondsTimerLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var dontHaveLastEventsWarningLabel: UILabel!
    
    @IBOutlet var comingEventContentView: UIView!
    @IBOutlet var myNavigationView: UIView!
    @IBOutlet var contentStackView: UIStackView!
    @IBOutlet var dontHaveNewEventsWarningLabel: UILabel!
    @IBOutlet var addNewEventButton: UIButton!
    @IBOutlet var deleteNewEventButton: UIButton!
    @IBOutlet var newEventBackgroundView: UIView!
    @IBOutlet var contestStartDateView: UIView!
    @IBOutlet var contestStartDateLabel: UILabel!
    @IBOutlet var joinEndDateView: UIView!
    @IBOutlet var joinEndDateLabel: UILabel!
    @IBOutlet var contestEndDateView: UIView!
    @IBOutlet var contestEndDateLabel: UILabel!
    @IBOutlet var resultsAnnouncementDateView: UIView!
    @IBOutlet var resultsAnnouncementDateLabel: UILabel!
    @IBOutlet var joinToNewContestButton: UIButton!
    @IBOutlet var alreadyHaveSubscriptionLabel: UILabel!
    
    @IBOutlet var addNewContestBackgroundView: UIView!
    @IBOutlet var startContestDatePicker: UIDatePicker!
    @IBOutlet var joinEndDatePicker: UIDatePicker!
    @IBOutlet var endContestDatePicker: UIDatePicker!
    @IBOutlet var announcementResultsDatePicker: UIDatePicker!
    @IBOutlet var passwordTextField: UITextField!
    
    // MARK: viewDidLoad()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
    }
    
    // MARK: viewWillAppear()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        startTimer()
        
        segmentedControl.isHidden = true
        freshNewsContentView.isHidden = true
        comingEventContentView.isHidden = true
        loadingIndicator.startAnimating()
        
        guard let currentUser = Auth.auth().currentUser else { return }
        ref.child("users").child(currentUser.uid).observe(DataEventType.value, with: { [ weak self ] snapshot in
            self?.currentAuthUser = UserProfileModel(snapshot: snapshot)
            
            self?.loadingIndicator.stopAnimating()
            switch self?.segmentedControl.selectedSegmentIndex {
            case 0:
                self?.comingEventContentView.isHidden = true
                self?.freshNewsContentView.isHidden = false
            case 1:
                self?.freshNewsContentView.isHidden = true
                self?.comingEventContentView.isHidden = false
            default:
                print("Selecting ERROR")
            }
        })
        
        ref.child("contests").observe(.value) { [ weak self ] snapshot  in
            self?.finishedContests = []
            
            for childSnapshot in snapshot.children {
                let thisContest = ContestModel(snapshot: childSnapshot as! DataSnapshot)
                
                if thisContest.status == .finished {
                    self?.finishedContests.append(thisContest)
                } else if thisContest.status == .new {
                    self?.newContest = thisContest
                }
            }
            
            self?.setupIBOutlets()
            self?.setupTableView()
            self?.tableView.reloadData()
            self?.setupInfoForNewContest()
        }
    }
    
    // MARK: - changeSegmentAction()
    
    @IBAction func changeSegmentAction(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            comingEventContentView.isHidden = true
            freshNewsContentView.isHidden = false
        case 1:
            freshNewsContentView.isHidden = true
            comingEventContentView.isHidden = false
        default:
            print("Selecting ERROR")
        }
    }
    
    // MARK: - IBActions for Main | openContestVCAction()
    
    @IBAction func openContestVCAction(_ sender: Any) {
        tabBarController?.selectedIndex = 1
    }
    
    // MARK: addNewContestAction()
    
    @IBAction func addNewContestAction(_ sender: Any) {
        addNewContestBackgroundView.isHidden = false
        contentStackView.alpha = 0.3
    }
    
    // MARK: deleteNewContestAction()
    
    @IBAction func deleteNewContestAction(_ sender: Any) {
        let deletingWarningAlert = UIAlertController(title: "УДАЛЕНИЕ", message:  "Вы уверены, что хотите удалить предстоящее событие?", preferredStyle: UIAlertController.Style.alert)
        let yesAction = UIAlertAction(title:  "Да", style: UIAlertAction.Style.destructive, handler: { [ weak self ] _ in
            self?.networkService.removeContest(contestModel: (self?.newContest)!)
            self?.newContest = nil
        })
        let cancelAction = UIAlertAction(title:  "Закрыть", style: UIAlertAction.Style.cancel)
        deletingWarningAlert.addAction(yesAction)
        deletingWarningAlert.addAction(cancelAction)
        
        present(deletingWarningAlert, animated: true)
    }
    
    // MARK: makeSubscriptionForThisContestAction()
    
    @IBAction func makeSubscriptionForThisContestAction(_ sender: Any) {
        currentAuthUser.newContestSubscriptionIsActive = true
        networkService.updateUserProfile(userProfileModel: currentAuthUser)
        
        joinToNewContestButton.isHidden = true
        alreadyHaveSubscriptionLabel.isHidden = false
    }
    
    // MARK: - IBActions for ModalView | addNewContestModalViewAction()
    
    @IBAction func addNewContestModalViewAction(_ sender: Any) {
        if startContestDatePicker.date.compare(joinEndDatePicker.date) == ComparisonResult.orderedAscending, joinEndDatePicker.date.compare(endContestDatePicker.date) == ComparisonResult.orderedAscending, endContestDatePicker.date.compare(announcementResultsDatePicker.date) == ComparisonResult.orderedAscending
        {
            createAndShowNewContest()
            
            contentStackView.alpha = 1
        }
    }
    
    // MARK: closeModalViewAction()
    
    @IBAction func closeModalViewAction(_ sender: Any) {
        addNewContestBackgroundView.isHidden = true
        
        contentStackView.alpha = 1
    }
    
    // MARK: - setupTableView()
    
    private func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
        
        let nib = UINib(nibName: "NewsCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: NewsCell.reuseId)
        
        tableView.backgroundColor = .clear
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }
    
    // MARK: setupIBOutlets()
    
    private func setupIBOutlets() {
        segmentedControl.isHidden = false
        
        freshNewsContentSubview.layer.cornerRadius = 10
        timerForCurrentContestView.layer.cornerRadius = 15
        
        myNavigationView.layer.cornerRadius = 10
        newEventBackgroundView.layer.cornerRadius = 15
        contestStartDateView.layer.cornerRadius = 15
        joinEndDateView.layer.cornerRadius = 15
        contestEndDateView.layer.cornerRadius = 15
        resultsAnnouncementDateView.layer.cornerRadius = 15
        
        addNewContestBackgroundView.layer.cornerRadius = 15
        
        dontHaveLastEventsWarningLabel.isHidden = true
        dontHaveNewEventsWarningLabel.isHidden = false
        alreadyHaveSubscriptionLabel.isHidden = true
        addNewContestBackgroundView.isHidden = true
        
        if !(currentAuthUser.isRoot) {
            addNewEventButton.isHidden = true
            deleteNewEventButton.isHidden = true
        } else {
            joinToNewContestButton.isEnabled = false
            
            if newContest != nil {
                addNewEventButton.isHidden = true
                deleteNewEventButton.isHidden = false
            } else {
                deleteNewEventButton.isHidden = true
                addNewEventButton.isHidden = false
            }
        }
    }
    
    // MARK: setupInfoForNewContest()
    
    private func setupInfoForNewContest() {
        if newContest != nil {
            dontHaveNewEventsWarningLabel.isHidden = true
            contestStartDateLabel.text = newContest.contestStartDateTime
            joinEndDateLabel.text = newContest.joinEndDateTime
            contestEndDateLabel.text = newContest.contestEndDateTime
            resultsAnnouncementDateLabel.text = newContest.resultsAnnouncementDateTime
            newEventBackgroundView.isHidden = false
            if currentAuthUser.newContestSubscriptionIsActive {
                joinToNewContestButton.isHidden = true
                alreadyHaveSubscriptionLabel.isHidden = false
            } else {
                alreadyHaveSubscriptionLabel.isHidden = true
                joinToNewContestButton.isHidden = false
            }
        } else {
            newEventBackgroundView.isHidden = true
            dontHaveNewEventsWarningLabel.isHidden = false
        }
    }
    
    // MARK: startTimer()
    
    private func startTimer() {
        let timeDateEnd = Date(timeIntervalSinceNow: 6)
        
        _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [ weak self ] timer in
            DispatchQueue.main.async {
                let timeDateNow = Date()
                let interval = timeDateEnd.timeIntervalSince(timeDateNow)
                
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
    
    // MARK: createAndShowNewContest()
    
    private func createAndShowNewContest() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM, hh:mm"
        dateFormatter.locale = Locale(identifier: "ru_RU")
        
        contestStartDateLabel.text = dateFormatter.string(from: startContestDatePicker.date)
        joinEndDateLabel.text = dateFormatter.string(from: joinEndDatePicker.date)
        contestEndDateLabel.text = dateFormatter.string(from: endContestDatePicker.date)
        resultsAnnouncementDateLabel.text = dateFormatter.string(from: announcementResultsDatePicker.date)
        
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "dd MMMM"
        dateFormatter2.locale = Locale(identifier: "ru_RU")
        let contest = ContestModel(date: dateFormatter2.string(from: startContestDatePicker.date),
                                   contestStartDateTime: dateFormatter.string(from: startContestDatePicker.date),
                                   joinEndDateTime: dateFormatter.string(from: joinEndDatePicker.date),
                                   contestEndDateTime: dateFormatter.string(from: endContestDatePicker.date),
                                   resultsAnnouncementDateTime: dateFormatter.string(from: announcementResultsDatePicker.date))
        ref.child("contests").child(contest.date).setValue(contest.convertToDictionary())
//        self.contest = contest
//        let newWinner = BestPlayer(username: "test2", email: "test1@mail.ru", score: 0, scoreDateTime: "dd MMMM", isMIP: true)
//        ref.child(contest.date).child("bestPlayers").child(newWinner.username).setValue(newWinner.convertToDictionary())
        
        addNewEventButton.isHidden = true
        deleteNewEventButton.isHidden = false
        newEventBackgroundView.isHidden = false
        addNewContestBackgroundView.isHidden = true
        dontHaveNewEventsWarningLabel.isHidden = true
    }
}


// MARK: - UITableViewDelegate, UITableViewDataSource

extension NewsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return finishedContests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NewsCell.reuseId, for: indexPath) as! NewsCell
        
        cell.set(contestModel: finishedContests[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 316
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let isRootFlag = currentAuthUser.isRoot
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ -> UIMenu? in
            
            // возможно удалить генерацию ссылок
            let shareButton = UIAction(title: "Поделиться", image: UIImage(systemName: "square.and.arrow.up")) { _ in
                print("here")
                // генерить ссылку на пост
            }
            var menu = UIMenu(title: "options", identifier: nil, options: [], children: [shareButton])

            if isRootFlag {
                let approveButton = UIAction(title: "Одобрить результаты", image: UIImage(systemName: "eye.trianglebadge.exclamationmark")) { _ in
                    print("here")
                    // менять статус поста на Одобренно
                }
                menu = UIMenu(title: "options", identifier: nil, options: [], children: [shareButton, approveButton])
            }
            
            return menu
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newsCellDetailVC: NewsCellDetailViewController = NewsCellDetailViewController.loadFromStoryboard()
        present(newsCellDetailVC, animated: true)
    }
}


// MARK: - NewsVCDelegate

extension NewsViewController: NewsVCDelegate {
    
    func setSecondSegmentedControlIndex() {
        segmentedControl.selectedSegmentIndex = 1
        
        freshNewsContentView.isHidden = true
        comingEventContentView.isHidden = false
    }
}




//        ref.child("contests").observe(.value) { [ weak self ] snapshot  in
//
//            var contests = [ContestModel]()
//
//            for child in snapshot.children {
//                var newContest = ContestModel(snapshot: child as! DataSnapshot)
//
////                var currentBestPlayers = [BestPlayer]()
//                self?.ref.child("contests").child(newContest.date).child("bestPlayers").observe(.value) { snapshot  in
//
//                    var newBestPlayer: BestPlayer!
//                    var currentBestPlayers = [BestPlayer]()
//
//                    for item in snapshot.children {
//                        newBestPlayer = BestPlayer(snapshot: item as! DataSnapshot)
//
//                        currentBestPlayers.append(newBestPlayer)
//                    }
//
////                    currentBestPlayers.append(newBestPlayer)
//
////                    print(currentBestPlayers)
//
////                    newContest = ContestModel(snapshot: child as! DataSnapshot, bestPlayersArray: currentBestPlayers)
//
////                    contests.append(newContest)
//                }
//
//                contests.append(newContest)
//            }
//
//            self?.finishedContests = contests
////            print(contests)
//            print(self?.finishedContests)
//        }
