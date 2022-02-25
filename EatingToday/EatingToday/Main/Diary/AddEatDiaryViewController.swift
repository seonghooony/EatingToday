//
//  AddEatDiaryViewController.swift
//  EatingToday
//
//  Created by SeongHoon Kim on 2022/02/23.
//

import UIKit
import SnapKit

class AddEatDiaryViewController: UIViewController {
    
    let headView = UIView()
    let titleLabel = UILabel()
    let registerButton = UIButton()
    let backButton = UIButton()
    
    let mainView = UIView()
    let mainScrollView = UIScrollView()
    let scrollContainerView = UIView()
    
    let storeNameView = UIView()
    let storeNameLabel = UILabel()
    let storeNameField = UITextField()
    
    let imageView = UIView()
    let imageLabel = UILabel()
    let imageUiView = UIView()
    let imagesUrl = [String()]
    
    let dateView = UIView()
    let dateLabel = UILabel()
    let datepicker = UIDatePicker()
    let date = Date()
    
    let locationView = UIView()
    let locationLabel = UILabel()
    let locationField = UITextField()
    let location = String()

    let scoreView = UIView()
    let scoreLabel = UILabel()
    let scoreUiView = UIView()
    let score = String()

    let categoryView = UIView()
    let categoryLabel = UILabel()
    let categoryField = UITextField()
    let category = String()

    let storyView = UIView()
    let storyLabel = UILabel()
    let storyField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewConfigure()
        constraintConfigure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @objc func back() {
        navigationController?.popViewController(animated: true)
    }
    
    func viewConfigure() {
        self.view.backgroundColor = .white
        
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
        
        self.view.addSubview(self.mainView)
        self.mainView.addSubview(mainScrollView)
        //self.mainScrollView.showsHorizontalScrollIndicator = false
        mainScrollView.isScrollEnabled = true
        
        self.mainScrollView.addSubview(scrollContainerView)
        self.scrollContainerView.backgroundColor = .brown
        
        self.scrollContainerView.addSubview(self.storeNameView)
        self.storeNameView.backgroundColor = .white
        self.storeNameView.layer.addBorder([.top, .bottom], color: UIColor.lightGray, width: 1.0)
        
        
        self.storeNameView.addSubview(self.storeNameLabel)
        self.storeNameLabel.text = "가게 이름"
        //self.storeNameLabel.textAlignment = .center
        
        self.storeNameView.addSubview(self.storeNameField)
        self.storeNameField.backgroundColor = .clear
        self.storeNameField.layer.cornerRadius = 20
        self.storeNameField.layer.addBorder([.all], color: .black, width: 2.0)
        
        
        self.scrollContainerView.addSubview(self.imageView)
        self.imageView.backgroundColor = .red
//        self.imageView.addSubview(self.imageLabel)
//        self.imageView.addSubview(self.imageUiView)
//        
//        self.mainScrollView.addSubview(self.dateView)
//        self.dateView.addSubview(self.dateLabel)
//        //self.dateView.addSubview(self.datepicker)
//        
//        self.mainView.addSubview(self.locationView)
//        self.locationView.addSubview(self.locationLabel)
//        self.locationView.addSubview(self.locationField)
//        
//        self.mainScrollView.addSubview(self.scoreView)
//        self.scoreView.addSubview(self.scoreLabel)
//        self.scoreView.addSubview(self.scoreUiView)
//        
//        self.mainView.addSubview(self.categoryView)
//        self.categoryView.addSubview(self.categoryLabel)
//        self.categoryView.addSubview(self.categoryField)
//        
//        self.mainScrollView.addSubview(self.storyView)
//        self.storyView.addSubview(self.storyLabel)
//        self.storyView.addSubview(self.storyField)
        
        
        
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
        
        self.mainView.snp.makeConstraints { make in
            make.top.equalTo(self.headView.snp.bottom).offset(0)
            make.leading.trailing.equalTo(self.view)
            make.bottom.equalToSuperview().offset(0)
        }
        
        self.mainScrollView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
            
        }
        
        self.scrollContainerView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalTo(self.mainScrollView.contentLayoutGuide)
            make.width.equalTo(self.mainScrollView.frameLayoutGuide)
            //make.height.equalTo(5000) //마지막 부분에 bottom 제약조건 안걸고 싶으면 고정 높이를 정해줘야함
            
        }
        
        self.storeNameView.snp.makeConstraints{ make in
            make.top.equalToSuperview().offset(0)
            //equalSuperview로 할경우 수평으로 스크롤 되는 현상 발생, 스크롤뷰이므로 가로세로가 무한이기때문에 정해줘야함
            make.leading.trailing.equalTo(self.view)
            make.height.equalTo(100)
        }

        self.storeNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(10)
            
        }
        
        self.storeNameField.snp.makeConstraints{ make in
            make.top.equalTo(storeNameLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(40)
            

        }
        
        self.imageView.snp.makeConstraints{ make in
            make.top.equalToSuperview().offset(1000)
            make.leading.trailing.equalTo(self.view)
            make.height.equalTo(200)
            make.bottom.equalToSuperview()//스크롤바가 고정높이가 아니라면 스크롤바의 마지막에 꼭 넣어줘야함.
        }
    }
}

extension CALayer {
    func addBorder(_ arr_edge: [UIRectEdge], color: UIColor, width: CGFloat) {
        for edge in arr_edge {
            let border = CALayer()
            switch edge {
            case UIRectEdge.top:
                border.frame = CGRect.init(x: 0, y: 0, width: frame.width, height: width)
                break
            case UIRectEdge.bottom:
                border.frame = CGRect.init(x: 0, y: frame.height - width, width: frame.width, height: width)
                break
            case UIRectEdge.left:
                border.frame = CGRect.init(x: 0, y: 0, width: width, height: frame.height)
                break
            case UIRectEdge.right:
                border.frame = CGRect.init(x: frame.width - width, y: 0, width: width, height: frame.height)
                break
            default:
                break
            }
            border.backgroundColor = color.cgColor;
            self.addSublayer(border)
        }
    }
}

