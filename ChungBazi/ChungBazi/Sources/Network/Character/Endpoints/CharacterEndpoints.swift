//
//  CharacterEndpoints.swift
//  ChungBazi
//
//  Created by 이현주 on 2/10/25.
//

import Foundation
import UIKit
import Moya

enum CharacterEndpoints {
    case fetchMainCharacter
    case fetchCharacterList
    case updateOpenCharacter(selectedLevel: String)
}

extension CharacterEndpoints: TargetType {
    public var baseURL: URL {
        guard let url = URL(string: API.characterURL) else {
            fatalError("잘못된 URL")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .fetchMainCharacter:
            return "/main-character"
        case .fetchCharacterList:
            return "/character-list"
        case .updateOpenCharacter:
            return "/select-or-open"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchMainCharacter, .fetchCharacterList:
            return .get
        case .updateOpenCharacter:
            return .patch
        }
    }
    
    var task: Task {
        switch self {
        case .fetchMainCharacter, .fetchCharacterList:
            return .requestPlain
        case .updateOpenCharacter(let selectedLevel):
            return .requestParameters(parameters: ["selectedLevel": selectedLevel], encoding: URLEncoding.queryString)
        }
    }
    
    
    var headers: [String : String]? {
        return ["Content-Type": "application/json"]
    }
}
