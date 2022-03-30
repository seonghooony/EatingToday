//
//  BottomSheetSelectedPlaceDetailViewController.swift
//  EatingToday
//
//  Created by SeongHoon Kim on 2022/03/30.
//

import UIKit

import Cosmos

class BottomSheetSelectedPlaceDetailViewController: UIViewController {
    
    var selectedDiaryInfos: Array<DiaryInfo>?
    var selectedPlaceName: String?
    var selectedPlaceAddress: String?
    var selectedPlaceCategory: String?
    
    let headerView = UIView()
    let titleLabel = UILabel()
    let addressLabel = UILabel()
    let categoryLabel = UILabel()
    let scoreLabel = CosmosView()
    
    let mainView = UIView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewConfigure()
        constraintConfigure()
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
    
    func viewConfigure() {
        
        self.view.backgroundColor = .white
        self.view.layer.cornerRadius = 5
        self.view.clipsToBounds = true
        
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
        
        self.view.addSubview(self.mainView)
        self.mainView.backgroundColor = .blue
    
    }
    
    
    func constraintConfigure() {
        let leadingtrailingSize = 20
        
        self.headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(100)
            
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
        
        self.mainView.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
            make.top.equalTo(self.headerView.snp.bottom)
        }
        
    
        
    }
    
}
