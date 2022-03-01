//
//  SearchKakaoViewController.swift
//  EatingToday
//
//  Created by SeongHoon Kim on 2022/03/01.
//
import Foundation
import UIKit
import Alamofire

public struct Place {
    let placeName: String
    let roadAddressName: String
    let longitudeX: String
    let latitudeY: String
}

class SearchKakaoViewController: UIViewController {
    
    var resultList = [Place]()
    var SearchKeyword: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchKakaoApiPlace()
    }
    
    func searchKakaoApiPlace() {
        
        let headers: HTTPHeaders = [
            "Authorization" : "KakaoAK 188f4e2c0a595ea58c5ffe55583061c1"
        ]
        let parameters: [String: Any] = [
            "query" : SearchKeyword ?? "강아지공원",
            "page" : 1,
            "size": 15
        ]
        let urlStr = "https://dapi.kakao.com/v2/local/search/keyword.json"
        let url = URL(string: urlStr)!
        
        AF.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: headers).responseJSON(completionHandler: { (response) in
            debugPrint(response)
            //데이터 세팅
            //테이블 뷰
            //검색란 만들기
            
        })
        
    }
    
    
}
