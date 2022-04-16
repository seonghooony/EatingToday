//
//  PopCategoryViewController.swift
//  EatingToday
//
//  Created by SeongHoon Kim on 2022/03/14.
//

import UIKit
import SnapKit

protocol setSelectedCategoryDelegate: AnyObject {
    func setSelectedCategory(categoryName: String)
}

class PopCategoryViewController: UIViewController {
    
    weak var setSelectedCategoryDelegate: setSelectedCategoryDelegate?
    
    let outsideUnderButton = UIButton()
    
    let popupView = UIView()
    let titleLabel = UILabel()
    
    let mainView = UIView()
    let closeButton = UIButton()
    
    var categoryCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical

        let collectionView = UICollectionView(frame: .init(x: 0, y: 0, width: 300, height: 300), collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor.clear
        
        return collectionView
    }()
    
    var foodImages: [UIImage] = [
        UIImage(named: "logo_koreanfood")!,  //0
        UIImage(named: "logo_chinesefood")!,  //1
        UIImage(named: "logo_japanesefood")!,  //2
        UIImage(named: "logo_westernfood")!,  //3
        UIImage(named: "logo_snackbarfood")!,  //4
        UIImage(named: "logo_meatfood")!,  //5
        UIImage(named: "logo_asianfood")!,  //6
        UIImage(named: "logo_dessert")!,  //7
        UIImage(named: "logo_etc")!]  //8
    
    var foodLabelNames: [String] = ["한식",   //0
                                    "중식",   //1
                                    "일식",   //2
                                    "양식",   //3
                                    "분식",   //4
                                    "구이",   //5
                                    "아시안",  //6
                                    "디저트",  //7
                                    "그외"]   //8
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewConfigure()
        self.constraintConfigure()
    }
    
    @objc private func popCloseTapped() {
        self.dismiss(animated: false, completion: nil)
    }
    
    private func viewConfigure() {
        
        self.view.addSubview(self.outsideUnderButton)
        self.outsideUnderButton.backgroundColor = .clear
        self.outsideUnderButton.setTitle(nil, for: .normal)
        self.outsideUnderButton.addTarget(self, action: #selector(popCloseTapped), for: .touchUpInside)
        
        self.view.addSubview(self.popupView)
        let shadowSize: CGFloat = 5.0
        self.popupView.layer.shadowPath = UIBezierPath(rect: CGRect(x: -shadowSize / 2, y: -shadowSize / 2, width: self.view.frame.size.width * 0.9 + shadowSize, height: self.view.frame.size.width * 0.9 + 80 + shadowSize)).cgPath
        self.popupView.layer.shadowColor = UIColor.black.cgColor
        self.popupView.layer.shadowOffset = .zero
        self.popupView.layer.shadowRadius = 8
        self.popupView.layer.shadowOpacity = 0.5
        self.popupView.layer.masksToBounds = false
        
        self.popupView.layer.cornerRadius = 15
        self.popupView.backgroundColor = .white
        
        self.popupView.addSubview(self.closeButton)
        self.closeButton.setImage(UIImage(named: "logo_close"), for: .normal)
        self.closeButton.tintColor = .darkGray
        self.closeButton.addTarget(self, action: #selector(popCloseTapped), for: .touchUpInside)
        
        self.popupView.addSubview(self.titleLabel)
        self.titleLabel.textColor = .black
        self.titleLabel.text = "맛집 카테고리"
        self.titleLabel.font = UIFont(name: "Helvetica Bold", size: 18)
        
        self.popupView.addSubview(self.mainView)
        
        self.categoryCollectionView.delegate = self
        self.categoryCollectionView.dataSource = self
        self.categoryCollectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: "CategoryCollectionViewCell")
        self.mainView.addSubview(self.categoryCollectionView)
        
    
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
            make.height.equalTo(self.view.frame.size.width * 0.9 + 80)
        }
        
        self.closeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(leadingTrailingSize - 2)
            make.trailing.equalToSuperview().offset(-leadingTrailingSize)
            make.width.height.equalTo(24)
        }
        
        self.closeButton.imageView?.snp.makeConstraints { make in
            make.height.width.equalTo(15)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(leadingTrailingSize - 2)
            make.leading.equalToSuperview().offset(leadingTrailingSize)
            make.height.equalTo(30)
        }
        
        self.mainView.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(leadingTrailingSize)
            make.trailing.equalToSuperview().offset(-leadingTrailingSize)
            make.bottom.equalToSuperview().offset(-leadingTrailingSize)
        }
        
        self.categoryCollectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    
    
}


extension PopCategoryViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    //셀 개수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return foodLabelNames.count
    }

    //셀 생성
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionViewCell", for: indexPath) as? CategoryCollectionViewCell else { return UICollectionViewCell() }
        print("생성 셀 인덱스 : \(indexPath.row)")
        
        cell.foodImageView.image = foodImages[indexPath.row]
        cell.categoryLabel.text = foodLabelNames[indexPath.row]
        
        return cell
    }



    //셀 클릭
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        setSelectedCategoryDelegate?.setSelectedCategory(categoryName: foodLabelNames[indexPath.row])
        self.dismiss(animated: false, completion: nil)
        

    }

    //셀 크기
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (self.categoryCollectionView.bounds.width / 3) - 10, height: (self.mainView.bounds.width / 3) - 10)
    }

    //셀간 최소간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 30
    }
}
