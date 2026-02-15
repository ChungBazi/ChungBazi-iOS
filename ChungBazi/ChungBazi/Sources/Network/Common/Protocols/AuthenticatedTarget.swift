//
//  AuthenticatedTarget.swift
//  ChungBazi
//
//  Created by 이현주 on 2/15/26.
//

import Moya

/// 인증 필요 여부를 명시하는 프로토콜
protocol AuthenticatedTarget: TargetType {
    /// 토큰 인증이 필요한지 여부
    var requiresAuthentication: Bool { get }
}
