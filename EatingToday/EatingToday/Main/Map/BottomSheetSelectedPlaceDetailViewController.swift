//
//  BottomSheetSelectedPlaceDetailViewController.swift
//  EatingToday
//
//  Created by SeongHoon Kim on 2022/03/30.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift
import FirebaseFirestore
import FirebaseCore
import Cosmos

class BottomSheetSelectedPlaceDetailViewController: UIViewController {
    
    var selectedDiaryInfos: Array<DiaryInfo>?
    var selectedPlaceName: String?
    var selectedPlaceAddress: String?
    var selectedPlaceCategory: String?
    var selectedDiaryFirstImageArrays = Array<UIImage>()
    var selectedDiaryImageArrays = Array<Array<UIImage>>()
    
    var currentPage: Int = 1
    let pagingSize = 3
    
    let headerView = UIView()
    let titleLabel = UILabel()
    let addressLabel = UILabel()
    let categoryLabel = UILabel()
    let scoreLabel = CosmosView()
    
    let lineView = UIView()
    
    let mainView = UIView()
    private lazy var mapDetailPlaceTableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.backgroundColor = .white
//        tableView.separatorStyle = .none
//        tableView.separatorColor = .white
        tableView.dataSource = self
        tableView.delegate = self
        //paging
//        tableView.prefetchDataSource = self
        tableView.register(MapDetailPlaceTableViewCell.self, forCellReuseIdentifier: "MapDetailPlaceTableViewCell")
        
        return tableView
    }()
    
    let toDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ko_KR")
        df.timeZone = TimeZone(abbreviation: "KST")
        df.dateFormat = "yyyy-MM-dd"
        
        return df
    }()
    
    let toStringDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ko_KR")
        df.timeZone = TimeZone(abbreviation: "KST")
        df.dateFormat = "yyyy년 M월 dd일 방문 스토리"
        
        return df
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        print("viewWillAppear \(selectedDiaryInfos)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewConfigure()
        self.constraintConfigure()
//        print("viewdidload \(selectedDiaryInfos)")
        self.downloadImages(currentPage: self.currentPage) { result in
            if result == "success" {
                DispatchQueue.main.async {
                    self.mapDetailPlaceTableView.reloadData()
                    print("이미지 다운로드 완료")
                }
            }
        }
        
    }
    
    func setStarScore() {
        
        var scoreAvg: Double = 0
        
        if let selectedDiaryInfos = self.selectedDiaryInfos {
            
            var scoreSum: Double = 0
            for diary in selectedDiaryInfos {
                scoreSum += diary.score!
            }
            
            scoreAvg = scoreSum / Double(selectedDiaryInfos.count)
        }
        
        self.scoreLabel.rating = scoreAvg
        self.scoreLabel.text = "\(String(format: "%.2f", scoreAvg))점"
    }
    
    func toStringDate(date: String?) -> String {
        
        if let date = date {
            let dateForm = toDateFormatter.date(from: date)
            if let dateForm = dateForm {
                let stringForm = toStringDateFormatter.string(from: dateForm)
                return stringForm
            }
        }
        
        
        
        
        return ""
        
    }
    

    func downloadImages(currentPage: Int, completion: @escaping (String) -> Void) {
        if let selectedDiaryInfos = self.selectedDiaryInfos {
            
            let startIndex = (self.currentPage - 1) * self.pagingSize
            let endIndex = self.currentPage * self.pagingSize > selectedDiaryInfos.count ? selectedDiaryInfos.count : self.currentPage * self.pagingSize
            
            for i in startIndex..<endIndex {
                if let _ = selectedDiaryInfos[i].images {
                    self.selectedDiaryFirstImageArrays.append(UIImage())
                }
            }
            
            var downloadCount = 0
            for i in startIndex..<endIndex {
                if let urls = selectedDiaryInfos[i].images {

                    self.downloadImage(urlString: urls[0]) { image in
                        if let image = image {
                            self.selectedDiaryFirstImageArrays[i] = image
                            downloadCount += 1
                            
                            print("endIndex - startIndex + 1 == downloadCount \(endIndex) - \(startIndex) + 1 == \(downloadCount)")
                            
                            if endIndex - startIndex == downloadCount {
                                completion("success")
                            }
                        }
                    }

                }

            }
        }
        
    }

    private func downloadImage(urlString: String, completion: @escaping (UIImage?) -> Void) {
        let storageReference = Storage.storage().reference(forURL: urlString)
        let megaByte = Int64(4 * 1024 * 1024)

        storageReference.getData(maxSize: megaByte) { data, error in
            if let error = error {
                print("Image Download Error : \(error.localizedDescription)")
            }

            guard let imageData = data else {
                completion(nil)
                return
            }
            completion(UIImage(data: imageData))
        }
    }
    
    func viewConfigure() {
        
        self.view.backgroundColor = .white
//        self.view.layer.cornerRadius = 5
//        self.view.clipsToBounds = true
        
        self.view.addSubview(self.headerView)
        self.headerView.backgroundColor = .white
        
        self.headerView.addSubview(self.titleLabel)
        self.titleLabel.text = self.selectedPlaceName
        self.titleLabel.textColor = .black
        self.titleLabel.font = UIFont(name: "Helvetica Bold", size: 18)
        
        self.headerView.addSubview(self.addressLabel)
        self.addressLabel.text = self.selectedPlaceAddress
        self.addressLabel.textColor = .darkGray
        self.addressLabel.font = UIFont(name: "Helvetica", size: 14)
        
        self.headerView.addSubview(self.categoryLabel)
        self.categoryLabel.text = self.selectedPlaceCategory
        self.categoryLabel.textColor = .lightGray
        self.categoryLabel.font = UIFont(name: "Helvetica", size: 15)
        
        self.headerView.addSubview(self.scoreLabel)
        self.scoreLabel.settings.fillMode = .precise
        self.scoreLabel.settings.starSize = 20
        self.scoreLabel.settings.starMargin = 5
        self.scoreLabel.settings.filledColor = .orange
        self.scoreLabel.settings.emptyColor = .white
        self.scoreLabel.settings.filledBorderColor = .orange
        self.scoreLabel.settings.filledBorderWidth = 0.5
        self.scoreLabel.settings.emptyBorderColor = .orange
        self.scoreLabel.settings.emptyBorderWidth = 0.5
        self.scoreLabel.isUserInteractionEnabled = false
        self.setStarScore()
        
        self.view.addSubview(self.lineView)
        self.lineView.backgroundColor = .lightGray
        
        self.view.addSubview(self.mainView)
        self.mainView.backgroundColor = .gray
        
        self.mainView.addSubview(self.mapDetailPlaceTableView)
    
    }
    
    
    func constraintConfigure() {
        let leadingtrailingSize = 20
        
        self.headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(110)
            
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().offset(leadingtrailingSize)
        }
        
        self.categoryLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.titleLabel.snp.trailing).offset(10)
            make.bottom.equalTo(self.titleLabel.snp.bottom)
        }
        
        self.addressLabel.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(leadingtrailingSize)
        }
        
        self.scoreLabel.snp.makeConstraints { make in
            make.top.equalTo(self.addressLabel.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(leadingtrailingSize)
        }
        
        self.lineView.snp.makeConstraints { make in
            make.top.equalTo(self.headerView.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(0.3)
        }
        
        
        self.mainView.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
            make.top.equalTo(self.lineView.snp.bottom)
        }
        
        self.mapDetailPlaceTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    
        
    }
    
}


extension BottomSheetSelectedPlaceDetailViewController: UITableViewDelegate {
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 140
//    }
//    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
//        return 500
    }
    
}

extension BottomSheetSelectedPlaceDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var endIndex = 0
        if let selectedDiaryInfos = self.selectedDiaryInfos {
            endIndex = self.currentPage * self.pagingSize > selectedDiaryInfos.count ? selectedDiaryInfos.count : self.currentPage * self.pagingSize
        }
        
        
        return endIndex
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MapDetailPlaceTableViewCell", for: indexPath) as? MapDetailPlaceTableViewCell
        
        
        
        cell?.dateLabel.text = toStringDate(date: self.selectedDiaryInfos?[indexPath.row].date)
        
        cell?.storyLabel.text = self.selectedDiaryInfos?[indexPath.row].story
        
        cell?.diaryScoreLabel.rating = Double(self.selectedDiaryInfos?[indexPath.row].score ?? 0.0)
        cell?.diaryScoreLabel.text = "\(self.selectedDiaryInfos?[indexPath.row].score ?? 0.0)점"
        
        
        cell?.firstImageView.image = self.selectedDiaryFirstImageArrays[indexPath.row]
        
        
        
        
        
        
        
        return cell ?? UITableViewCell()
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print("보여질 셀: \(indexPath.row)")
        
        if (indexPath.row + 1)/pagingSize == currentPage {
            self.currentPage += 1
            print("self.currentPage : \(self.currentPage)")
            
            self.downloadImages(currentPage: self.currentPage) { result in
                if result == "success" {
                    
                    DispatchQueue.main.async {
                        self.mapDetailPlaceTableView.reloadData()
                        print("이미지 다운로드 완료")
                    }
                    
                }
            }
            
            

        }
    }
    
}
