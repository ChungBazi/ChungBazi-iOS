//
//  CalendarRequestDTOs.swift
//  ChungBazi
//
//  Created by 이현주 on 1/27/25.
//

import Foundation

struct CalendarRequestDTO: Codable {
    let yearMonth: String
}

//이거를 리스트화해서 보냄
struct UpdateDocuments: Codable {
    let documentId: Int
    let content: String
}

//이거를 리스트화해서 보냄
struct UpdateCheck: Codable {
    let documentId: Int
    let checked: Bool
}

struct PostDocumentsRequestDto: Codable {
    let documents: [String]
}
