//
//  UserDiaryInfo.swift
//  EatingToday
//
//  Created by SeongHoon Kim on 2022/03/17.
//

import Foundation
import UIKit

struct UserDiaryInfo: Codable {
    let diary: Array<String>?
    let profileImageURL: String?
    let nickname: String?
}
