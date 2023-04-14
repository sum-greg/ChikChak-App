//
//  UserProfileModel.swift
//  ChikChak App
//
//  Created by Григорий Сумлинский on 11.02.2023.
//

import Foundation
import Firebase


// MARK: - UserProfileModel struct

struct UserProfileModel {
    let ref: DatabaseReference?
    
    var uid: String
    var username: String
    var email: String
    var isRoot: Bool = false
    var bestScore: Int = 0
    var attemptsCount: Int = 0
    
    var allNotif: Bool = true
    var announceNewContestNotif: Bool = true
    var startEndContestNotif: Bool = true
    var changeYourPositionNotif: Bool = true
    
    var currentContestSubscriptionIsActive: Bool = false
    var newContestSubscriptionIsActive: Bool = false
    
    // MARK: init(params)
    
    init(uid: String, username: String, email: String) {
        self.ref = nil
        
        self.uid = uid
        self.username = username
        self.email = email
    }
    
    // MARK: init(snapshot)
    
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as! [String: AnyObject]
        
        ref = snapshot.ref
        
        uid = snapshotValue["uid"] as! String
        username = snapshotValue["username"] as! String
        email = snapshotValue["email"] as! String
        isRoot = snapshotValue["isRoot"] as! Bool
        bestScore = snapshotValue["bestScore"] as! Int
        attemptsCount = snapshotValue["attemptsCount"] as! Int
        
        allNotif = snapshotValue["allNotif"] as! Bool
        announceNewContestNotif = snapshotValue["announceNewContestNotif"] as! Bool
        startEndContestNotif = snapshotValue["startEndContestNotif"] as! Bool
        changeYourPositionNotif = snapshotValue["changeYourPositionNotif"] as! Bool
        
        currentContestSubscriptionIsActive = snapshotValue["currentContestSubscriptionIsActive"] as! Bool
        newContestSubscriptionIsActive = snapshotValue["newContestSubscriptionIsActive"] as! Bool
    }
    
    // MARK: - convertToDictionary()
    
    func convertToDictionary() -> Any {
        return [
            "uid": uid,
            "username": username,
            "email": email,
            "isRoot": isRoot,
            "bestScore": bestScore,
            "attemptsCount": attemptsCount,
            "allNotif": allNotif,
            "announceNewContestNotif": announceNewContestNotif,
            "startEndContestNotif": startEndContestNotif,
            "changeYourPositionNotif": changeYourPositionNotif,
            "currentContestSubscriptionIsActive": currentContestSubscriptionIsActive,
            "newContestSubscriptionIsActive": newContestSubscriptionIsActive
        ]
    }
}
