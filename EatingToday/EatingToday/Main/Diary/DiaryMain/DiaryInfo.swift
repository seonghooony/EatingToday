//
//  DiaryInfo.swift
//  EatingToday
//
//  Created by SeongHoon Kim on 2022/03/17.
//

import Foundation
import UIKit

struct DiaryInfo: Codable {
    let place_info: SelectedSearchResultDocument?
    let date: String?
    let category: String?
    let score: Double?
    let story: String?
    let images: Array<String>?
}
