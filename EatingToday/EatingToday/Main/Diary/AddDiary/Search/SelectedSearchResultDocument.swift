//
//  SelectedSearchResultDocument.swift
//  EatingToday
//
//  Created by SeongHoon Kim on 2022/03/06.
//

import Foundation

struct SelectedSearchResultDocument: Codable {
    let address_name: String?
    let road_address_name: String?
    let phone: String?
    let place_name: String?
    let place_url: String?
    let x: String?
    let y: String?
}
