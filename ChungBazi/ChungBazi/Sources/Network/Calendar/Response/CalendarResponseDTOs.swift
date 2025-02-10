//
//  CalendarResponseDTOs.swift
//  ChungBazi
//
//  Created by 이현주 on 1/27/25.
//

import Foundation

//typealias CalendarResponseDTO = ApiResponse<[PolicyDTO]?>

struct CalendarResponseDTO: Decodable {
    let name: String?
    let startDate: String?
    let endDate: String?
}
