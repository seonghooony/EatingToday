//
//  AddEatDiaryViewController.swift
//  EatingToday
//
//  Created by SeongHoon Kim on 2022/02/23.
//

import UIKit

class AddEatDiaryViewController: UIViewController {
    
    let headView = UIView()
    let titleLabel = UILabel()
    let registerButton = UIButton()
    let backButton = UIButton()
    
    let mainView = UIView()

    let storeNameLabel = UILabel()
    let storeNameField = UITextField()

    let imageLabel = UILabel()
    let imageUiView = UIView()
    let imagesUrl = [String()]

    let dateLabel = UILabel()
    let datepicker = UIDatePicker()
    let date = Date()

    let locationLabel = UILabel()
    let locationField = UITextField()
    let location = String()

    let scoreLabel = UILabel()
    let scoreUiView = UIView()
    let score = String()

    let categoryLabel = UILabel()
    let categoryField = UITextField()
    let category = String()

    let storyLabel = UILabel()
    let storyField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewConfigure()
        constraintConfigure()
    }
    
    @objc func back() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func viewConfigure() {
        self.view.backgroundColor = .white
        
//        self.titleLabel.text = "Eatingram"
//        self.titleLabel.font = UIFont(name: "Marker Felt", size: 20)
//        self.titleLabel.textColor = UIColor(displayP3Red: 243/255, green: 129/255, blue: 129/255, alpha: 1)
//        self.titleLabel.sizeToFit()
//        self.navigationItem.titleView = titleLabel
//
//        registerButton.title = "등록"
//        registerButton.tintColor = UIColor(displayP3Red: 1/255, green: 1/255, blue: 1/255, alpha: 1)
//        self.navigationItem.rightBarButtonItem = registerButton
//
        
//        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .done, target: self, action: #selector(back))
//        backButton.tintColor = UIColor(displayP3Red: 1/255, green: 1/255, blue: 1/255, alpha: 1)
//        self.navigationItem.leftBarButtonItem = backButton
        
        self.view.addSubview(self.headView)
        self.headView.addSubview(self.backButton)
        self.backButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        self.backButton.tintColor = UIColor(displayP3Red: 1/255, green: 1/255, blue: 1/255, alpha: 1)
        self.backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        
        self.headView.addSubview(self.titleLabel)
        self.titleLabel.text = "Eatingram"
        self.titleLabel.textAlignment = .center
        self.titleLabel.font = UIFont(name: "Marker Felt", size: 25)
        self.titleLabel.textColor = UIColor(displayP3Red: 243/255, green: 129/255, blue: 129/255, alpha: 1)
        
        self.headView.addSubview(self.registerButton)
        self.registerButton.setTitle("등록", for: .normal)
        self.registerButton.setTitleColor(UIColor(displayP3Red: 1/255, green: 1/255, blue: 1/255, alpha: 1), for: .normal)
         
        //self.view.addSubview(self.mainView)
        
    }
    
    func constraintConfigure() {
        self.headView.snp.makeConstraints{ make in
            make.top.equalToSuperview().offset(0)
            make.height.equalTo(100)
            make.leading.equalToSuperview().offset(0)
            make.trailing.equalToSuperview().offset(0)
        }
        
        self.backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(50)
            make.height.equalTo(50)
            
        }
        
        self.titleLabel.snp.makeConstraints{ make in
            make.top.equalToSuperview().offset(50)
            make.height.equalTo(50)
            make.centerX.equalToSuperview()
        }
        
        self.registerButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.top.equalToSuperview().offset(50)
            make.height.equalTo(50)
            
        }
    }
}
