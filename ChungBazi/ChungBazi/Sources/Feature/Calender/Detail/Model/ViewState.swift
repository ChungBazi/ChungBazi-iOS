//
//  ViewState.swift
//  ChungBazi
//
//  Created by 이현주 on 2/18/25.
//

enum ViewState {
    case empty      // 문서가 하나도 없는 상태 (EmptyView)
    case viewing    // 기존 문서 리스트를 보는 상태 (NotEmptyView)
    case adding     // 새로운 문서를 추가하는 상태 (AddingView)
    case editing    // 기존 문서를 수정하는 상태 (EditingView)
}
