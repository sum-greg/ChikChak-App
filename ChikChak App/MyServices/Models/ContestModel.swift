//
//  ContestModel.swift
//  ChikChak App
//
//  Created by Григорий Сумлинский on 11.02.2023.
//

import Foundation
import Firebase


// MARK: - StatusOptions enum

enum StatusOptions: String {
    case new = "new"
    case current = "current"
    case finished = "finished"
}

// MARK: - ContestModel struct

struct ContestModel {
    let ref: DatabaseReference?
    
    var status: StatusOptions = .new
    var isApproved: Bool = false
    
    var date: String
    var contestStartDateTime: String
    var joinEndDateTime: String
    var contestEndDateTime: String
    var resultsAnnouncementDateTime: String
    
    var prizeAmount: String = "0.0"
    var playersAmount: Int = 0
    
    var bestPlayers = [BestPlayer]()
    
    // MARK: init(params)
    
    init(date: String, contestStartDateTime: String, joinEndDateTime: String, contestEndDateTime: String, resultsAnnouncementDateTime: String) {
        self.ref = nil
        self.date = date
        self.contestStartDateTime = contestStartDateTime
        self.joinEndDateTime = joinEndDateTime
        self.contestEndDateTime = contestEndDateTime
        self.resultsAnnouncementDateTime = resultsAnnouncementDateTime
    }
    
    // MARK: init(snapshot)
    
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as! [String: AnyObject]
        
        ref = snapshot.ref
        
        let statusString = snapshotValue["status"] as! String
        status = StatusOptions.init(rawValue: statusString)!
        isApproved = snapshotValue["isApproved"] as! Bool
        
        date = snapshotValue["date"] as! String
        contestStartDateTime = snapshotValue["contestStartDateTime"] as! String
        joinEndDateTime = snapshotValue["joinEndDateTime"] as! String
        contestEndDateTime = snapshotValue["contestEndDateTime"] as! String
        resultsAnnouncementDateTime = snapshotValue["resultsAnnouncementDateTime"] as! String
        
        prizeAmount = snapshotValue["prizeAmount"] as! String
        playersAmount = snapshotValue["playersAmount"] as! Int
    }
    
    // MARK: - convertToDictionary()
    
    func convertToDictionary() -> Any {
        return [
            "status": status.rawValue,
            "isApproved": isApproved,
            "date": date,
            "contestStartDateTime": contestStartDateTime,
            "joinEndDateTime": joinEndDateTime,
            "contestEndDateTime": contestEndDateTime,
            "resultsAnnouncementDateTime": resultsAnnouncementDateTime,
            "prizeAmount": prizeAmount,
            "playersAmount": playersAmount
        ]
    }
}

// MARK: - BestPlayer struct

struct BestPlayer {
    let ref: DatabaseReference?
    
    var username: String
    var email: String
    var score: Int
    var scoreDateTime: String
    var isMIP: Bool
    
    // MARK: init(params)
    
    init(username: String, email: String, score: Int, scoreDateTime: String, isMIP: Bool) {
        self.ref = nil
        
        self.username = username
        self.email = email
        self.score = score
        self.scoreDateTime = scoreDateTime
        self.isMIP = isMIP
    }
    
    // MARK: init(snapshot)
    
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as! [String: AnyObject]
        
        ref = snapshot.ref
        
        username = snapshotValue["username"] as! String
        email = snapshotValue["email"] as! String
        score = snapshotValue["score"] as! Int
        scoreDateTime = snapshotValue["scoreDateTime"] as! String
        isMIP = snapshotValue["isMIP"] as! Bool
    }
    
    // MARK: - convertToDictionary()
    
    func convertToDictionary() -> Any {
        return [
            "username": username,
            "email": email,
            "score": score,
            "scoreDateTime": scoreDateTime,
            "isMIP": isMIP
        ]
    }
}

