//
//  SearchResultOverview.swift
//  EatingToday
//
//  Created by SeongHoon Kim on 2022/03/01.
//

import Foundation

struct SearchResultOverview: Codable {
    
    let documents: [Document]
    
}
struct Document: Codable {
    let address_name: String
    let road_address_name: String
    let phone: String
    let place_name: String
    let place_url: String
    let x: String
    let y: String
}
