//
//  NetworkService.swift
//  ChikChak App
//
//  Created by Григорий Сумлинский on 11.02.2023.
//

import UIKit
import Firebase


// MARK: - NetworkService class

class NetworkService {
    
    var ref = Database.database().reference()
    
    // MARK: updateUserProfile()
    
    func updateUserProfile(userProfileModel: UserProfileModel) {
        ref.child("users").child(userProfileModel.uid).setValue(userProfileModel.convertToDictionary())
    }
    
    // MARK: removeUserProfile()
    
    func removeUserProfile(userProfileModel: UserProfileModel) {
        ref.child("users").child(userProfileModel.uid).setValue(nil)
    }
    
    // MARK: removeContest()
    
    func removeContest(contestModel: ContestModel) {
        ref.child("contests").child(contestModel.date).setValue(nil)
    }
}
