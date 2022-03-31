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
    var selectedDiaryImageArrays = Array<Array<UIImage>>()
    
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
        self.downloadImages() { result in
            if result == "success" {
                self.mapDetailPlaceTableView.reloadData()
                print("이미지 다운로드 완료")
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
    

    func downloadImages(completion: @escaping (String) -> Void) {
        if let selectedDiaryInfos = selectedDiaryInfos {
            for i in 0..<selectedDiaryInfos.count {
                self.selectedDiaryImageArrays.append(Array<UIImage>())
                if let urls = selectedDiaryInfos[i].images {
                    var imageDataList = Array<UIImage>()

                    for _ in 0..<urls.count {
                        imageDataList.append(UIImage())
                    }
                    self.selectedDiaryImageArrays[i] = imageDataList
                }
            }

            for i in 0..<selectedDiaryInfos.count {
                if let urls = selectedDiaryInfos[i].images {
                    //print("\(i)번째 url들 :\(urls)")

                    var completeDownCount = 0
                    for j in 0..<urls.count {
                        self.downloadImage(urlString: urls[j]) { image in
                            if let image = image {
    //                            imageDataList[j] = image
                                self.selectedDiaryImageArrays[i][j] = image
                                completeDownCount += 1

                                if completeDownCount == urls.count {
                                    completion("success")
                                }
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
}

extension BottomSheetSelectedPlaceDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.selectedDiaryInfos?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MapDetailPlaceTableViewCell", for: indexPath) as? MapDetailPlaceTableViewCell
        
        
        
        cell?.dateLabel.text = toStringDate(date: self.selectedDiaryInfos?[indexPath.row].date)
        
        cell?.storyLabel.text = self.selectedDiaryInfos?[indexPath.row].story
        
        cell?.diaryScoreLabel.rating = Double(self.selectedDiaryInfos?[indexPath.row].score ?? 0.0)
        cell?.diaryScoreLabel.text = "\(self.selectedDiaryInfos?[indexPath.row].score ?? 0.0)점"
        
        
        cell?.firstImageView.image = self.selectedDiaryImageArrays[indexPath.row][0]
        
        
        
        
        
        return cell ?? UITableViewCell()
    }
    
    
}
