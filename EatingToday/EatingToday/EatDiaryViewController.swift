//
//  EatDiaryViewController.swift
//  EatingToday
//
//  Created by SeongHoon Kim on 2022/02/21.
//

import UIKit

class EatDiaryViewController: UIViewController {
    
    let headView = UIView()
    let titleButton = UIButton()
    let diaryAddButton = UIButton()
    let mainView = UIView()
//    let boardCollectionView = UICollectionView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.viewConfigure()
        self.constraintConfigure()
    }
    
    func viewConfigure() {
        
        self.view.addSubview(self.headView)
        self.headView.backgroundColor = .white
        
        self.headView.addSubview(titleButton)
        self.titleButton.setTitle("Eatingram", for: .normal)
        self.titleButton.setTitleColor(UIColor(displayP3Red: 243/255, green: 129/255, blue: 129/255, alpha: 1), for: .normal)
        self.titleButton.titleLabel?.textAlignment = .center
        self.titleButton.titleLabel?.font = UIFont(name: "Marker Felt", size: 25)
        
        self.headView.addSubview(diaryAddButton)
        self.diaryAddButton.setImage(UIImage(systemName: "plus"), for: .normal)
        self.diaryAddButton.imageView?.tintColor = .black
        
        self.view.addSubview(self.mainView)
        self.mainView.backgroundColor = .white
        
    }
    
    func constraintConfigure() {
        self.headView.snp.makeConstraints{ make in
            make.top.equalToSuperview().offset(0)
            make.height.equalTo(100)
            make.leading.equalToSuperview().offset(0)
            make.trailing.equalToSuperview().offset(0)
        }
        
        self.titleButton.snp.makeConstraints{ make in
            make.top.equalToSuperview().offset(50)
            make.height.equalTo(50)
            make.leading.equalToSuperview().offset(20)
            //make.trailing.equalToSuperview().offset(0)
        }
        
        self.diaryAddButton.snp.makeConstraints{ make in
            make.top.equalToSuperview().offset(50)
            make.height.equalTo(50)
            //make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        self.mainView.snp.makeConstraints{ make in
            make.top.equalTo(self.headView.snp.bottom).offset(0)
            make.bottom.equalToSuperview().offset(0)
            make.leading.equalToSuperview().offset(0)
            make.trailing.equalToSuperview().offset(0)
        }
    }
        

}
