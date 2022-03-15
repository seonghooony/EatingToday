//
//  RegisterDiaryInfo.swift
//  EatingToday
//
//  Created by SeongHoon Kim on 2022/03/15.
//

import Foundation
import UIKit

struct RegisterDiaryInfo: Codable {
    let place_info: SelectedSearchResultDocument?
    let date: Date?
    let category: String?
    let score: Double?
    let story: String?
    let images: Array<String>?
}
