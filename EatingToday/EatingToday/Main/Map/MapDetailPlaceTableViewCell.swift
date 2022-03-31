//
//  MapDetailPlaceTableViewCell.swift
//  EatingToday
//
//  Created by SeongHoon Kim on 2022/03/31.
//

import UIKit
import Cosmos

class MapDetailPlaceTableViewCell: UITableViewCell {
    
    let headerView = UIView()
    
    let leadingSideView = UIView()
    let firstImageView = UIImageView()
    
    let trailingSideView = UIView()
    let dateLabel = UILabel()
    let storyLabel = UILabel()

    
    let footerView = UIView()
    let diaryScoreLabel = CosmosView()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.viewConfigure()
        self.constraintConfigure()

    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:)has not been implemented")
    }
    
    
    func viewConfigure() {
        
        self.addSubview(self.headerView)
        self.headerView.backgroundColor = .white
        
        self.headerView.addSubview(self.leadingSideView)
        self.leadingSideView.addSubview(self.firstImageView)
        self.firstImageView.layer.cornerRadius = 40
        self.firstImageView.clipsToBounds = true
        self.firstImageView.image = UIImage(systemName: "doc.text.image")
        
        self.headerView.addSubview(self.trailingSideView)
        self.trailingSideView.addSubview(self.dateLabel)
        self.dateLabel.text = "방문 날짜"
        self.dateLabel.textAlignment = .left
        self.dateLabel.textColor = .gray
        self.dateLabel.font = UIFont(name: "Helvetica Bold", size: 13)
        
        self.trailingSideView.addSubview(self.storyLabel)
        self.storyLabel.text = "이야기"
        self.storyLabel.textAlignment = .left
        self.storyLabel.lineBreakMode = .byCharWrapping
        self.storyLabel.numberOfLines = 0
        self.storyLabel.textColor = .black
        self.storyLabel.font = UIFont(name: "Helvetica", size: 15)
        

        
        self.addSubview(self.footerView)
        self.footerView.backgroundColor = .white
        self.footerView.addSubview(self.diaryScoreLabel)
        self.diaryScoreLabel.settings.fillMode = .half
        self.diaryScoreLabel.settings.starSize = 15
        self.diaryScoreLabel.settings.starMargin = 3
        self.diaryScoreLabel.settings.filledColor = .orange
        self.diaryScoreLabel.settings.emptyColor = .white
        self.diaryScoreLabel.settings.filledBorderColor = .orange
        self.diaryScoreLabel.settings.filledBorderWidth = 0.3
        self.diaryScoreLabel.settings.emptyBorderColor = .orange
        self.diaryScoreLabel.settings.emptyBorderWidth = 0.3
        self.diaryScoreLabel.isUserInteractionEnabled = false
        
    }
    
    func constraintConfigure() {
        let leadingTrailingSize = 20
        
        self.headerView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(120)
            
        }
        
        self.leadingSideView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(120)
        }
        self.firstImageView.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().offset(20)
            make.trailing.bottom.equalToSuperview().offset(-20)
        }
        
        self.trailingSideView.snp.makeConstraints { make in
            make.leading.equalTo(self.leadingSideView.snp.trailing)
            make.trailing.top.bottom.equalToSuperview()
        }
        
        self.dateLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(0)
            make.top.equalToSuperview().offset(leadingTrailingSize)
            make.trailing.equalToSuperview().offset(-leadingTrailingSize)
            make.height.equalTo(20)
        }
        self.storyLabel.snp.makeConstraints { make in
            make.top.equalTo(self.dateLabel.snp.bottom)
            make.bottom.trailing.equalToSuperview().offset(-leadingTrailingSize)
            make.leading.equalToSuperview().offset(0)
            
        }
        
        
        
        self.footerView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(self.headerView.snp.bottom)
        }
        
        self.diaryScoreLabel.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview().offset(-leadingTrailingSize)
//            make.centerY.equalToSuperview()
        }
        
    }
    
}
