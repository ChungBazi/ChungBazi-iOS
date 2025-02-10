//
//  CharacterService.swift
//  ChungBazi
//
//  Created by 이현주 on 2/10/25.
//

import Foundation
import UIKit
import Moya

final class CharacterService: NetworkManager {
    
    typealias Endpoint = CharacterEndpoints
    
    // MARK: - Provider 설정
    let provider: MoyaProvider<CharacterEndpoints>
    
    public init(provider: MoyaProvider<CharacterEndpoints>? = nil) {
        // 플러그인 추가
        let plugins: [PluginType] = [
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose)) // 로그 플러그인
        ]
        
        // provider 초기화
        self.provider = provider ?? MoyaProvider<CharacterEndpoints>(plugins: plugins)
    }

    //MARK: - API funcs
    /// 메인 캐릭터 조회 API
    public func fetchMainCharacter(completion: @escaping (Result<MainCharacterResponseDto, NetworkError>) -> Void) {
        request(target: .fetchMainCharacter, decodingType: MainCharacterResponseDto.self, completion: completion)
    }
    
    /// 보유 캐릭터 리스트 조회 API
    public func fetchCharacterList(completion: @escaping (Result<[CharacterListResponseDto], NetworkError>) -> Void) {
        request(target: .fetchCharacterList, decodingType: [CharacterListResponseDto].self, completion: completion)
    }
    
    /// 개별 캐릭터 선택 및 오픈 API
    public func updateOpenCharacter(selectedLevel: String, completion: @escaping (Result<MainCharacterResponseDto, NetworkError>) -> Void) {
        request(target: .updateOpenCharacter(selectedLevel: selectedLevel), decodingType: MainCharacterResponseDto.self, completion: completion)
    }
}
