//
//  ProfileModel.swift
//  ChungBazi
//
//  Created by 신호연 on 1/25/25.
//

import Foundation

struct ProfileModel: Decodable {
    let userId: Int
    var name: String
    let email: String
    var characterImg: String
}

struct RewardModel {
    let currentReward: Int
    let myPosts: Int
    let myComments: Int
}

public struct CharacterImage {
    static let level1 = "LEVEL_1"
    static let level2 = "LEVEL_2"
    static let level3 = "LEVEL_3"
    static let level4 = "LEVEL_4"
    static let level5 = "LEVEL_5"
    static let level6 = "LEVEL_6"
    static let level7 = "LEVEL_7"
    static let level8 = "LEVEL_8"
    static let level9 = "LEVEL_9"
    static let level10 = "LEVEL_10"
    
    public static let levelMapping: [String: Int] = [
        level1: 1,
        level2: 2,
        level3: 3,
        level4: 4,
        level5: 5,
        level6: 6,
        level7: 7,
        level8: 8,
        level9: 9,
        level10: 10
    ]
    
    public static let allCases = [level1, level2, level3, level4, level5, level6, level7, level8, level9, level10]
    public static let `default` = level1
}
