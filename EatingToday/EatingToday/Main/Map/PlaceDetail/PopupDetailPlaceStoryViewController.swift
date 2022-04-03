//
//  PopupDetailPlaceStoryViewController.swift
//  EatingToday
//
//  Created by SeongHoon Kim on 2022/04/03.
//

import UIKit
import FSPagerView
import Cosmos

class PopupDetailPlaceStoryViewController: UIViewController {
    
    var selectedDiaryInfo: DiaryInfo?
    
    let outsideUnderButton = UIButton()
    
    private lazy var popupView: UIView = {
        let popView = UIView()
        let shadowSize: CGFloat = 5.0
        popView.layer.shadowPath = UIBezierPath(rect: CGRect(x: -shadowSize / 2, y: -shadowSize / 2, width: self.view.frame.size.width * 0.9 + shadowSize, height: self.view.frame.size.height * 0.8 + shadowSize)).cgPath
        popView.backgroundColor = .white
        popView.layer.cornerRadius = 10
        popView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        popView.layer.shadowOffset = CGSize(width: 1, height: 4)
        popView.layer.shadowRadius = 15
        popView.layer.shadowOpacity = 1
        
        popView.layer.masksToBounds = false
        popView.layer.shouldRasterize = true
        popView.layer.rasterizationScale = UIScreen.main.scale
        
        popView.layer.cornerRadius = 15
        popView.backgroundColor = .white
        

        return popView
    }()
    
    let headView = UIView()
    let titleStackView = UIView()
    let titleLabel = UILabel()
    let locationLabel = UILabel()
    let closeButton = UIButton()
    
    let imageMainView = UIView()
    let pagerView = FSPagerView()
    
    let infoContentView = UIView()
    let infoTitleLabel = UILabel()
    let scoreLabel = CosmosView()
    

    let dateLabel = UILabel()
    let storyScrollView = UIScrollView()
    let storyLabel = UILabel()

    
//    let contentsFooterView = UIView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewConfigure()
        self.constraintConfigure()
        
    }
    
    @objc private func popCloseTapped() {
        self.dismiss(animated: false, completion: nil)
    }
    
    private func viewConfigure() {
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        self.view.addSubview(self.outsideUnderButton)
        self.outsideUnderButton.backgroundColor = .clear
        self.outsideUnderButton.setTitle(nil, for: .normal)
        self.outsideUnderButton.addTarget(self, action: #selector(popCloseTapped), for: .touchUpInside)
        
        
        self.view.addSubview(self.popupView)
        
        self.popupView.addSubview(headView)
        self.headView.backgroundColor = .white
        
        self.headView.addSubview(self.titleStackView)
        
        self.titleStackView.addSubview(titleLabel)
        self.titleLabel.text = self.selectedDiaryInfo?.place_info?.place_name
        self.titleLabel.textAlignment = .center
        self.titleLabel.textColor = .black
        self.titleLabel.font = UIFont(name: "Helvetica Bold", size: 17)
        
        self.titleStackView.addSubview(self.locationLabel)
        self.locationLabel.text = self.selectedDiaryInfo?.place_info?.address_name
        self.locationLabel.textAlignment = .center
        self.locationLabel.textColor = .lightGray
        self.locationLabel.font = UIFont(name: "Helvetica", size: 13)
        
        self.headView.addSubview(self.closeButton)
        self.closeButton.setImage(UIImage(named: "logo_close"), for: .normal)
        self.closeButton.tintColor = .darkGray
        self.closeButton.addTarget(self, action: #selector(popCloseTapped), for: .touchUpInside)
        
        self.popupView.addSubview(self.imageMainView)
        
        self.pagerView.dataSource = self
        self.pagerView.delegate = self
        self.pagerView.transformer = FSPagerViewTransformer(type: .linear)
        self.pagerView.itemSize = CGSize(width: UIScreen.main.bounds.width * 0.7, height: UIScreen.main.bounds.width * 0.9)
        self.pagerView.interitemSpacing = 5
        
        self.pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        self.imageMainView.addSubview(self.pagerView)
        
        self.popupView.addSubview(self.infoContentView)
        
        self.infoContentView.addSubview(self.scoreLabel)
        self.scoreLabel.settings.fillMode = .half
        self.scoreLabel.settings.starSize = 20
        self.scoreLabel.settings.starMargin = 5
        self.scoreLabel.settings.filledColor = .orange
        self.scoreLabel.settings.emptyColor = .white
        self.scoreLabel.settings.filledBorderColor = .orange
        self.scoreLabel.settings.filledBorderWidth = 0.5
        self.scoreLabel.settings.emptyBorderColor = .orange
        self.scoreLabel.settings.emptyBorderWidth = 0.5
        self.scoreLabel.isUserInteractionEnabled = false
        self.scoreLabel.rating = Double(self.selectedDiaryInfo?.score ?? 0.0)
        self.scoreLabel.text = "\(self.selectedDiaryInfo?.score ?? 0.0)점"
        
        
        self.infoContentView.addSubview(self.dateLabel)
//        self.dateLabel.text = "날짜"
        if let cellDate = self.selectedDiaryInfo?.date {
            self.dateLabel.text = "\(cellDate) 방문"
        }
        self.dateLabel.textAlignment = .center
        self.dateLabel.textColor = .lightGray
        self.dateLabel.font = UIFont(name: "Helvetica", size: 13)
        
        self.infoContentView.addSubview(self.storyScrollView)
        self.storyScrollView.isScrollEnabled = true
        
        self.storyScrollView.addSubview(self.storyLabel)
        self.storyLabel.text = self.selectedDiaryInfo?.story
        self.storyLabel.lineBreakMode = .byCharWrapping
        self.storyLabel.textAlignment = .left
        self.storyLabel.textColor = .black
        self.storyLabel.numberOfLines = 0
        self.storyLabel.font = UIFont(name: "Helvetica", size: 15)
        self.storyLabel.sizeToFit()
        
    }
    
    private func constraintConfigure() {
        
        let leadingTrailingSize = 20
        
        self.outsideUnderButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.popupView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
//            make.height.equalToSuperview().multipliedBy(0.3)
            make.height.equalToSuperview().multipliedBy(0.8)
        }
        
        self.headView.snp.makeConstraints{ make in
            make.top.equalToSuperview().offset(20)
            make.height.equalTo(50)
            make.leading.equalToSuperview().offset(0)
            make.trailing.equalToSuperview().offset(0)
        }
        self.titleStackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.height.equalTo(40)
            make.leading.equalToSuperview()
            make.width.equalTo(250)
        }
        
        self.titleLabel.snp.makeConstraints{ make in
            make.bottom.equalTo(self.titleStackView.snp.centerY).offset(2)

            make.leading.equalToSuperview().offset(20)
//            make.trailing.equalToSuperview().offset(0)
        }
        
        self.locationLabel.snp.makeConstraints { make in
            make.top.equalTo(self.titleStackView.snp.centerY).offset(3)

            make.leading.equalToSuperview().offset(20)
        }
        
        self.closeButton.snp.makeConstraints { make in
            make.top.equalTo(self.popupView.snp.top).offset(20)
            make.width.height.equalTo(24)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        self.closeButton.imageView?.snp.makeConstraints { make in
            make.height.width.equalTo(15)
        }
        
        self.imageMainView.snp.makeConstraints { make in
            make.top.equalTo(self.headView.snp.bottom).offset(0)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(UIScreen.main.bounds.width)
        }
        
        self.pagerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.infoContentView.snp.makeConstraints { make in
            make.top.equalTo(self.imageMainView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
            
        }
        
        self.scoreLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
//            make.top.equalTo(self.infoTitleLabel.snp.bottom).offset(10)
            make.height.equalTo(22)
            make.leading.equalToSuperview().offset(leadingTrailingSize)
        }
        
        self.dateLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            
            make.trailing.equalToSuperview().offset(-leadingTrailingSize)
        }
        
        self.storyScrollView.snp.makeConstraints { make in
            make.top.equalTo(self.scoreLabel.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(leadingTrailingSize)
            make.bottom.trailing.equalToSuperview().offset(-leadingTrailingSize)
        }

        self.storyLabel.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalTo(self.storyScrollView.contentLayoutGuide)
            make.width.equalTo(self.storyScrollView.frameLayoutGuide)
            
//            make.top.equalTo(self.scoreLabel.snp.bottom).offset(20)
//            make.leading.equalToSuperview().offset(leadingTrailingSize)
//            make.trailing.equalToSuperview().offset(-leadingTrailingSize)
//            make.height.greaterThanOrEqualTo(10)
        }
        
    }
}


extension PopupDetailPlaceStoryViewController: FSPagerViewDataSource {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return self.selectedDiaryInfo?.images?.count ?? 0
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        cell.isUserInteractionEnabled = false
        if let imageUrl: String = self.selectedDiaryInfo?.images![index] {
            print("url 주소 : \(imageUrl)")
            let url = URL(string: imageUrl)
            cell.imageView?.contentMode = .scaleAspectFill
            cell.imageView?.clipsToBounds = true
            cell.imageView?.kf.indicatorType = .activity
            cell.imageView?.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(0.5))], progressBlock: nil)
        }
        
        
        return cell
    }
}

extension PopupDetailPlaceStoryViewController: FSPagerViewDelegate {
    
    
}
