//
//  ProfileModel.swift
//  ChungBazi
//
//  Created by 신호연 on 1/25/25.
//

import Foundation

struct ProfileModel: Codable {
    let userId: Int
    let name: String
    let email: String
    let profileImg: String
}

struct RewardModel {
    let currentReward: Int
    let myPosts: Int
    let myComments: Int
}
